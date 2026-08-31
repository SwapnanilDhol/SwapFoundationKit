#!/usr/bin/env python3
"""Small, build-free regression tests for the API baseline parser."""

import json
import os
import pathlib
import subprocess
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[2]
PARSER = ROOT / "Scripts" / "api-baseline-parse.py"


def run_parser(graph_dir, targets):
    env = os.environ.copy()
    env.update(
        REPO_ROOT=str(ROOT),
        SYMBOL_GRAPH_DIR=str(graph_dir),
        TARGETS=" ".join(targets),
    )
    return subprocess.run(
        ["python3", str(PARSER)], env=env, text=True, capture_output=True
    )


def symbol_graph(path, uri):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(
            {
                "symbols": [
                    {
                        "accessLevel": "public",
                        "kind": {"identifier": "swift.struct"},
                        "pathComponents": ["Fixture"],
                        "location": {"uri": uri, "position": {"line": 2}},
                    }
                ]
            }
        )
    )


with tempfile.TemporaryDirectory() as temp, tempfile.TemporaryDirectory(
    dir=ROOT / "Sources"
) as source_temp:
    graph_dir = pathlib.Path(temp) / "graphs"
    source_with_space = pathlib.Path(source_temp) / "fixture source.swift"
    symbol_graph(
        graph_dir / "Fixture.symbols.json",
        "file://" + str(source_with_space).replace(" ", "%20"),
    )
    result = run_parser(graph_dir, ["Fixture"])
    assert result.returncode == 0, result.stderr
    assert "fixture source.swift:3" in result.stdout

    missing = run_parser(graph_dir, ["Fixture", "Missing"])
    assert missing.returncode != 0
    assert "Missing" in missing.stderr

print("api-baseline parser tests: OK")
