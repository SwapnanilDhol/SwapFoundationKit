#!/usr/bin/env python3
"""Build-free regression tests for the v4 static acceptance gate."""

import json
import pathlib
import subprocess
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "Scripts/v4-acceptance.py"


class AcceptanceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp.name)
        (self.root / "Sources").mkdir()
        (self.root / "Docs/migration").mkdir(parents=True)
        (self.root / "Docs/development").mkdir(parents=True)
        for path in ("Sources/Fixture.swift", "Docs/fixture.md", "Sources/example.swift"):
            target = self.root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("// fixture\n")

    def tearDown(self):
        self.temp.cleanup()

    def run_gate(self, *, rows=None, source="enum PrivateRegistry { private static var factory: (() -> Void)? }", budgets=None, capabilities=None, migration=None, counts=None):
        baseline = self.root / "Docs/development/api-baseline.txt"
        baseline.write_text("## SYMBOLS\n" + "\n".join(rows or ["SwapFoundationKit | struct | Sources/Fixture.swift:1 | Fixture"]) + "\n")
        (self.root / "Sources/Fixture.swift").write_text(source)
        (self.root / "Docs/development/v4-api-budgets.json").write_text(json.dumps(budgets or {
            "limits": {"default_top_level_types": 75, "ui_top_level_types": 39, "all_product_top_level_types": 157, "all_initializer_max_labels": 10},
            "common_constructor_prefixes": {"Fixture": 6},
            "obsolete_public_roots": [],
        }))
        (self.root / "Docs/capabilities.yaml").write_text(capabilities or json.dumps({"domains": [{"id": "fixture", "summary": "Fixture", "source_files": ["Sources/Fixture.swift"], "docs": ["Docs/fixture.md"], "examples": ["Sources/example.swift"]}]}))
        (self.root / "Docs/migration/catalog.yaml").write_text(migration or json.dumps({"capabilities": [{"id": "fixture", "module": "SwapFoundationKit", "replace_with": ["Fixture"], "migration": {"replacement": ["Fixture"], "compatibility": "canonical", "removal_release": None}, "source_files": ["Sources/Fixture.swift"], "docs": ["Docs/fixture.md"], "examples": ["Sources/example.swift"]}]}))
        (self.root / "Docs/development/catalog-counts.json").write_text(json.dumps(counts or {"domains": 1, "capabilities": 1}))
        return subprocess.run(["python3", str(SCRIPT), "--repo-root", str(self.root)], text=True, capture_output=True)

    def test_valid_private_registry(self):
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_over_budget(self):
        result = self.run_gate(budgets={"limits": {"default_top_level_types": 0, "ui_top_level_types": 0, "all_product_top_level_types": 0, "all_initializer_max_labels": 10}, "obsolete_public_roots": []})
        self.assertIn("surface budget exceeded", result.stderr)

    def test_oversized_initializer(self):
        row = "SwapFoundationKit | struct | Sources/Fixture.swift:1 | Fixture.init(a:b:c:d:e:f:g:h:i:j:k:)"
        result = self.run_gate(rows=[row])
        self.assertIn("initializer exceeds 10 labels", result.stderr)

    def test_forbidden_public_root(self):
        result = self.run_gate(rows=["SwapFoundationKit | struct | Sources/Fixture.swift:1 | Forbidden"], budgets={"limits": {"default_top_level_types": 75, "ui_top_level_types": 39, "all_product_top_level_types": 157, "all_initializer_max_labels": 10}, "obsolete_public_roots": ["Forbidden"]})
        self.assertIn("obsolete public API root", result.stderr)

    def test_multiline_and_public_extension_closures(self):
        source = """public static var direct: (
    (String) -> Void
)?

public extension Fixture {
    private static var hidden: (() -> Void)?
    static var inherited: (() -> Bool)?
}"""
        result = self.run_gate(source=source)
        self.assertGreaterEqual(result.stderr.count("mutable public static closure"), 2)

    def test_stale_path_and_count(self):
        capabilities = json.dumps({"domains": [{"id": "fixture", "summary": "Fixture", "source_files": ["Sources/missing.swift"], "docs": ["Docs/fixture.md"], "examples": ["Sources/example.swift"]}]})
        result = self.run_gate(capabilities=capabilities, counts={"domains": 99, "capabilities": 99})
        self.assertIn("nonexistent source_files path", result.stderr)
        self.assertIn("catalog counts stale", result.stderr)

    def test_duplicate_catalog_id(self):
        capabilities = json.dumps({"domains": [{"id": "fixture", "summary": "Fixture", "source_files": [], "docs": [], "examples": []}, {"id": "fixture", "summary": "Fixture", "source_files": [], "docs": [], "examples": []}]})
        result = self.run_gate(capabilities=capabilities, counts={"domains": 2, "capabilities": 1})
        self.assertIn("duplicate id", result.stderr)


if __name__ == "__main__":
    unittest.main()
