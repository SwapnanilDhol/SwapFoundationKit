#!/usr/bin/env python3
"""Static v4 acceptance checks.

This is deliberately source-only.  API counts come from the generated symbol
graph baseline; Swift source is used only for the closure-property and catalog
checks.  It is not a Swift parser, and reports the documented limitations when
it rejects a declaration.
"""
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys
from collections import Counter


TYPE_KINDS = {"class", "struct", "enum", "protocol", "typealias"}


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def read_json(path: pathlib.Path, errors: list[str]):
    try:
        return json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        fail(errors, f"{path}: invalid JSON: {exc}")
        return None


def baseline_rows(path: pathlib.Path, errors: list[str]):
    rows = []
    try:
        in_symbols = False
        for number, line in enumerate(path.read_text().splitlines(), 1):
            if line == "## SYMBOLS":
                in_symbols = True
                continue
            if not in_symbols or not line or line.startswith("#"):
                continue
            parts = [part.strip() for part in line.split(" | ", 3)]
            if len(parts) != 4:
                fail(errors, f"{path}:{number}: malformed symbol row")
                continue
            target, kind, location, symbol = parts
            rows.append((target, kind, location, symbol))
    except OSError as exc:
        fail(errors, f"{path}: cannot read baseline: {exc}")
    return rows


def initializer_labels(symbol: str) -> int | None:
    match = re.search(r"\.init\(([^()]*)\)$", symbol)
    if not match:
        return None
    # Symbol-graph initializer paths encode argument labels, so each colon is
    # one label.  Types are not present in this path component.
    return match.group(1).count(":")


def validate_surface(rows, budgets, errors):
    if not isinstance(budgets, dict):
        fail(errors, "budgets: expected a JSON object")
        return
    limits = budgets.get("limits", budgets)
    by_target = Counter(
        target
        for target, kind, _location, symbol in rows
        if kind in TYPE_KINDS and "." not in symbol
    )
    default = by_target.get("SwapFoundationKit", 0)
    ui = sum(
        1
        for target, kind, location, symbol in rows
        if target == "SwapFoundationKit"
        and kind in TYPE_KINDS
        and "." not in symbol
        and "/UI/" in location
    )
    all_types = sum(by_target.values())
    measured = {"default_top_level_types": default, "ui_top_level_types": ui, "all_product_top_level_types": all_types}
    for key, value in measured.items():
        limit = limits.get(key)
        if not isinstance(limit, int):
            fail(errors, f"budgets: missing integer limit {key}")
        elif value > limit:
            fail(errors, f"surface budget exceeded: {key} measured {value}, limit {limit}")

    common = budgets.get("common_constructor_prefixes", {})
    for target, kind, location, symbol in rows:
        labels = initializer_labels(symbol)
        if labels is None:
            continue
        if labels > int(limits.get("all_initializer_max_labels", 10)):
            fail(errors, f"initializer exceeds 10 labels: {symbol} ({labels}) at {location}")
        for prefix, max_labels in common.items():
            if symbol.startswith(prefix + ".init("):
                if labels > int(max_labels):
                    fail(errors, f"common constructor exceeds {max_labels} labels: {symbol} ({labels}) at {location}")
                break

    for root in budgets.get("obsolete_public_roots", []):
        matches = [row for row in rows if symbol_matches_root(row[3], root)]
        for _target, _kind, location, symbol in matches:
            fail(errors, f"obsolete public API root {root}: {symbol} at {location}")


def symbol_matches_root(symbol: str, root: str) -> bool:
    return symbol == root or symbol.startswith(root + ".") or symbol.startswith(root + "(")


def strip_comments_and_strings(text: str) -> str:
    # This small lexer preserves newlines so diagnostics retain useful line
    # numbers.  It intentionally handles Swift line/block comments and quoted
    # strings; interpolation and multiline strings are conservative.
    out = list(text)
    i = 0
    state = "code"
    while i < len(text):
        if state == "code" and text.startswith("//", i):
            out[i] = " "
            out[i + 1] = " "
            state = "line"
            i += 2
            continue
        if state == "code" and text.startswith("/*", i):
            out[i] = " "
            out[i + 1] = " "
            state = "block"
            i += 2
            continue
        if state == "code" and text[i] == '"':
            out[i] = " "
            state = "string"
            i += 1
            continue
        if state == "line":
            if text[i] == "\n":
                state = "code"
            else:
                out[i] = " "
            i += 1
            continue
        if state == "block":
            if text.startswith("*/", i):
                out[i] = " "
                out[i + 1] = " "
                state = "code"
                i += 2
            else:
                if text[i] != "\n":
                    out[i] = " "
                i += 1
            continue
        if state == "string":
            if text[i] == "\\":
                out[i] = " "
                if i + 1 < len(text) and text[i + 1] != "\n":
                    out[i + 1] = " "
                    i += 2
                else:
                    i += 1
            elif text[i] == '"':
                out[i] = " "
                state = "code"
                i += 1
            else:
                if text[i] != "\n":
                    out[i] = " "
                i += 1
            continue
        i += 1
    return "".join(out)


def closure_type(declaration: str) -> bool:
    return "->" in declaration and ("(" in declaration or "@Sendable" in declaration)


def property_declaration(text: str, start: int) -> str:
    """Return a type declaration without consuming later members.

    Closure types may span lines, while ordinary computed properties can have
    a brace body. Parenthesis depth is enough for the type grammar we need.
    """
    depth = 0
    end = start
    while end < len(text):
        character = text[end]
        if character == "(":
            depth += 1
        elif character == ")":
            depth = max(0, depth - 1)
        elif character == "=" and depth == 0:
            break
        elif character == "\n" and depth == 0:
            break
        end += 1
    return text[start:end]


def public_static_closures(source_root: pathlib.Path):
    findings = []
    for path in sorted(source_root.rglob("*.swift")):
        cleaned = strip_comments_and_strings(path.read_text())
        # Explicit access declarations, including multiline declarations. Use
        # a bounded look-ahead instead of a dot-star-to-end regex: large Swift
        # files otherwise trigger catastrophic backtracking.
        pattern = re.compile(r"\bpublic\s+static\s+var\s+([A-Za-z_][A-Za-z0-9_]*)\b")
        for match in pattern.finditer(cleaned):
            declaration = property_declaration(cleaned, match.end())
            if closure_type(declaration):
                findings.append((path, cleaned[: match.start()].count("\n") + 1, match.group(1)))

        # Members of `public extension` inherit public access even when the
        # member omits the modifier. Brace matching is intentionally lexical.
        for extension in re.finditer(r"\bpublic\s+extension\b[^\{]*\{", cleaned):
            start = extension.end()
            depth = 1
            index = start
            while index < len(cleaned) and depth:
                if cleaned[index] == "{":
                    depth += 1
                elif cleaned[index] == "}":
                    depth -= 1
                index += 1
            body = cleaned[start:index]
            member_pattern = re.compile(r"\bstatic\s+var\s+([A-Za-z_][A-Za-z0-9_]*)\b")
            for member in member_pattern.finditer(body):
                # Access modifiers apply to the declaration's line. Limiting
                # this to the current line avoids mistaking a preceding
                # private/internal member for an inherited-public one.
                line_start = body.rfind("\n", 0, member.start()) + 1
                access_prefix = body[line_start : member.start()]
                if re.search(r"\b(?:private|internal|fileprivate|package)\s+$", access_prefix):
                    continue
                declaration = property_declaration(body, member.end())
                if closure_type(declaration):
                    line = cleaned[: start + member.start()].count("\n") + 1
                    findings.append((path, line, member.group(1)))
    return findings


def load_yaml(path: pathlib.Path, errors: list[str]):
    try:
        import yaml  # type: ignore
    except ImportError:
        # JSON is a YAML subset.  This fallback keeps fixture checks useful on
        # minimal developer machines; CI installs the pinned PyYAML parser for
        # the real catalogs.
        try:
            return json.loads(path.read_text())
        except (OSError, json.JSONDecodeError) as exc:
            fail(errors, f"{path}: PyYAML is unavailable and catalog is not JSON: {exc}")
            return None
    try:
        return yaml.safe_load(path.read_text())
    except (OSError, yaml.YAMLError) as exc:
        fail(errors, f"{path}: invalid YAML: {exc}")
        return None


def validate_catalog(path: pathlib.Path, repo_root: pathlib.Path, errors: list[str], migration: bool):
    data = load_yaml(path, errors)
    if not isinstance(data, dict):
        return 0
    key = "capabilities" if migration else "domains"
    entries = data.get(key)
    if not isinstance(entries, list):
        fail(errors, f"{path}: missing list {key}")
        return 0
    if not entries:
        fail(errors, f"{path}: {key} must not be empty")
        return 0
    seen = set()
    for entry in entries:
        if not isinstance(entry, dict) or not entry.get("id"):
            fail(errors, f"{path}: entry missing non-empty id")
            continue
        identifier = entry["id"]
        if identifier in seen:
            fail(errors, f"{path}: duplicate id {identifier}")
        seen.add(identifier)
        for field in ("source_files", "docs", "examples"):
            values = entry.get(field, [])
            if values is None:
                values = []
            if not isinstance(values, list):
                fail(errors, f"{path}: {identifier}: {field} must be a list")
                continue
            for value in values:
                if not (repo_root / value).exists():
                    fail(errors, f"{path}: {identifier}: nonexistent {field} path {value}")
        if migration:
            if not entry.get("module"):
                fail(errors, f"{path}: {identifier}: missing owning module")
            migration_data = entry.get("migration")
            if not isinstance(migration_data, dict):
                fail(errors, f"{path}: {identifier}: migration must be an object")
                migration_data = {}
            replacement = migration_data.get("replacement")
            replace_with = entry.get("replace_with")
            if not isinstance(replace_with, list) or not replace_with:
                fail(errors, f"{path}: {identifier}: missing/empty replace_with")
            if replacement != replace_with:
                fail(errors, f"{path}: {identifier}: migration replacement must equal replace_with")
            if migration_data.get("compatibility") not in {"canonical", "removed"}:
                fail(errors, f"{path}: {identifier}: incomplete migration metadata")
            if "removal_release" not in migration_data:
                fail(errors, f"{path}: {identifier}: missing migration removal_release")
    return len(entries)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=pathlib.Path, default=pathlib.Path(__file__).resolve().parents[1])
    parser.add_argument("--baseline")
    parser.add_argument("--budgets")
    parser.add_argument("--source-root")
    parser.add_argument("--capabilities")
    parser.add_argument("--migration-catalog")
    parser.add_argument("--catalog-counts")
    args = parser.parse_args()
    root = args.repo_root.resolve()
    errors: list[str] = []
    baseline = pathlib.Path(args.baseline) if args.baseline else root / "Docs/development/api-baseline.txt"
    budgets_path = pathlib.Path(args.budgets) if args.budgets else root / "Docs/development/v4-api-budgets.json"
    rows = baseline_rows(baseline, errors)
    budgets = read_json(budgets_path, errors)
    if not rows:
        fail(errors, f"{baseline}: empty baseline symbol inventory")
    if budgets is not None:
        validate_surface(rows, budgets, errors)
    source_root = pathlib.Path(args.source_root) if args.source_root else root / "Sources"
    for path, line, name in public_static_closures(source_root):
        fail(errors, f"mutable public static closure: {path}:{line} ({name})")

    capabilities = pathlib.Path(args.capabilities) if args.capabilities else root / "Docs/capabilities.yaml"
    migration = pathlib.Path(args.migration_catalog) if args.migration_catalog else root / "Docs/migration/catalog.yaml"
    cap_count = validate_catalog(capabilities, root, errors, False)
    migration_count = validate_catalog(migration, root, errors, True)
    obsolete = budgets.get("obsolete_public_roots", []) if isinstance(budgets, dict) else []
    for catalog_path, catalog_key in ((capabilities, "domains"), (migration, "capabilities")):
        catalog = load_yaml(catalog_path, errors)
        if not isinstance(catalog, dict):
            continue
        entries = catalog.get(catalog_key, [])
        for entry in entries if isinstance(entries, list) else []:
            for field in ("public_symbols", "public_api", "replace_with"):
                values = entry.get(field, []) if isinstance(entry, dict) else []
                for value in values if isinstance(values, list) else []:
                    for root_name in obsolete:
                        if symbol_matches_root(str(value), root_name):
                            fail(errors, f"{catalog_path}: removed public symbol {value} remains advertised in {field}")
    counts_path = pathlib.Path(args.catalog_counts) if args.catalog_counts else root / "Docs/development/catalog-counts.json"
    if not counts_path.exists():
        fail(errors, f"{counts_path}: missing tracked catalog counts")
    else:
        tracked = read_json(counts_path, errors)
        if isinstance(tracked, dict):
            if tracked.get("domains") != cap_count or tracked.get("capabilities") != migration_count:
                fail(errors, f"catalog counts stale: tracked domains/capabilities {tracked.get('domains')}/{tracked.get('capabilities')}, actual {cap_count}/{migration_count}")

    if errors:
        print("v4 acceptance: FAILED", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"v4 acceptance: OK (domains={cap_count}, capabilities={migration_count})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
