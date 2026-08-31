#!/bin/sh
# Check that the default SwapFoundationKit target has no optional vendor edge.
# This deliberately uses POSIX shell and BSD grep/sed so it can run on macOS CI
# and locally without a project-specific runtime.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SOURCE_ROOT="$REPO_ROOT/Sources/SwapFoundationKit"
SKIP_PACKAGE_CHECK=0
PACKAGE_JSON=""

usage() {
    echo "Usage: $0 [--source-root DIR] [--package-describe-json FILE] [--skip-package-check]" >&2
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --source-root)
            [ "$#" -ge 2 ] || { usage; exit 2; }
            SOURCE_ROOT=$2
            shift 2
            ;;
        --package-describe-json)
            [ "$#" -ge 2 ] || { usage; exit 2; }
            PACKAGE_JSON=$2
            shift 2
            ;;
        --skip-package-check)
            SKIP_PACKAGE_CHECK=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 2
            ;;
    esac
done

[ -d "$SOURCE_ROOT" ] || { echo "dependency-gate: source root not found: $SOURCE_ROOT" >&2; exit 2; }

# Keep this expression intentionally conservative: it accepts Swift import
# attributes/access modifiers before `import`, catches PulseUI/PulseProxy and
# every Firebase* module, and does not depend on GNU-only \b or \s escapes.
FORBIDDEN_IMPORT='^[[:space:]]*((@[[:alnum:]_]+|public|private|internal|package|fileprivate)[[:space:]]+)*import[[:space:]]+((class|struct|enum|protocol|func|var)[[:space:]]+)?(Pulse[[:alnum:]_]*|Toast[[:alnum:]_]*|GoogleMobileAds[[:alnum:]_]*|Firebase[[:alnum:]_]*)([.]|[[:space:]]|$)'
# Restrict the scan to Swift source; module READMEs intentionally contain
# migration examples with opt-in imports.
MATCHES=$(/usr/bin/find "$SOURCE_ROOT" -type f -name '*.swift' -exec /usr/bin/grep -HnE "$FORBIDDEN_IMPORT" {} + 2>/dev/null || true)
VIOLATIONS=""

if [ -n "$MATCHES" ]; then
    while IFS=: read -r file line source_line; do
        module=$(/usr/bin/printf '%s\n' "$source_line" | /usr/bin/sed -E 's/.*import[[:space:]]+([A-Za-z_][A-Za-z0-9_]*).*/\1/')
        allowed=0
        if [ "$file" = "$REPO_ROOT/Sources/SwapFoundationKit/Services/Analytics/SFKFirebaseLogger.swift" ] \
            && [ "$module" = "FirebaseAnalytics" ]; then
            # The only exception is the Firebase adapter, and only while its
            # import is lexically guarded by #if canImport(FirebaseAnalytics).
            if /usr/bin/awk -v target="$line" '
                function has_can_import_guard(   i) {
                    for (i = 1; i <= depth; i++)
                        if (kind[i] == "can" && branch[i] == 1) return 1
                    return 0
                }
                NR < target {
                    if ($0 ~ /^[[:space:]]*#if[[:space:]]+canImport\(FirebaseAnalytics\)/) {
                        depth++; kind[depth] = "can"; branch[depth] = 1
                    } else if ($0 ~ /^[[:space:]]*#if([[:space:]]|$)/) {
                        depth++; kind[depth] = "other"; branch[depth] = 1
                    } else if ($0 ~ /^[[:space:]]*#(else|elseif)([[:space:]]|$)/ && depth > 0) {
                        branch[depth] = 0
                    } else if ($0 ~ /^[[:space:]]*#endif([[:space:]]|$)/ && depth > 0) {
                        delete kind[depth]; delete branch[depth]; depth--
                    }
                }
                END { exit(has_can_import_guard() ? 0 : 1) }
            ' "$file"; then
                allowed=1
            fi
        fi
        if [ "$allowed" -eq 0 ]; then
            VIOLATIONS="${VIOLATIONS}${file}:${line}:${source_line}\n"
        fi
    done <<EOF
$MATCHES
EOF
fi

if [ -n "$VIOLATIONS" ]; then
    echo "dependency-gate: forbidden vendor imports in the default target:" >&2
    /usr/bin/printf '%b' "$VIOLATIONS" >&2
    exit 1
fi
echo "dependency-gate: no forbidden vendor imports under $SOURCE_ROOT."

if [ "$SKIP_PACKAGE_CHECK" -eq 0 ]; then
    if [ -z "$PACKAGE_JSON" ]; then
        PACKAGE_JSON=$(mktemp "${TMPDIR:-/tmp}/sfk-package-describe.XXXXXX")
        trap 'rm -f "$PACKAGE_JSON"' EXIT
        swift package describe --type json > "$PACKAGE_JSON"
    fi
    REPO_ROOT="$REPO_ROOT" PACKAGE_JSON="$PACKAGE_JSON" python3 - <<'PY'
import json
import os
import sys

with open(os.environ["PACKAGE_JSON"]) as stream:
    package = json.load(stream)

targets = {target["name"]: target for target in package.get("targets", [])}
if "SwapFoundationKit" not in targets:
    print("dependency-gate: missing SwapFoundationKit target in package description", file=sys.stderr)
    sys.exit(1)

# A future refactor may add a local target between the default target and a
# vendor product. Walk all reachable local targets instead of checking only
# SwapFoundationKit's direct product_dependencies.
reachable = set()
pending = ["SwapFoundationKit"]
missing = []
while pending:
    name = pending.pop()
    if name in reachable:
        continue
    if name not in targets:
        missing.append(name)
        continue
    reachable.add(name)
    pending.extend(targets.get(name, {}).get("target_dependencies") or [])

if missing:
    print("dependency-gate: reachable target is missing from package description:", file=sys.stderr)
    print("  " + "\n  ".join(sorted(set(missing))), file=sys.stderr)
    sys.exit(1)

non_library = [
    name for name in sorted(reachable)
    if targets[name].get("type") != "library"
]
if non_library:
    print("dependency-gate: reachable default-target dependency is not a library target:", file=sys.stderr)
    print("  " + "\n  ".join(non_library), file=sys.stderr)
    sys.exit(1)

bad = []
for name in sorted(reachable):
    for product in targets.get(name, {}).get("product_dependencies") or []:
        bad.append(f"{name} -> {product}")
if bad:
    print("dependency-gate: reachable default-target vendor products:", file=sys.stderr)
    print("  " + "\n  ".join(bad), file=sys.stderr)
    sys.exit(1)

print("dependency-gate: no third-party products reachable from SwapFoundationKit.")
PY
fi
