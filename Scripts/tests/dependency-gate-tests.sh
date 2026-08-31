#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
GATE="$ROOT/Scripts/dependency-gate.sh"
FIXTURES="$SCRIPT_DIR/fixtures/dependency-gate"

"$GATE" --source-root "$ROOT/Sources/SwapFoundationKit" --skip-package-check >/dev/null
"$GATE" --source-root "$FIXTURES/clean" --skip-package-check >/dev/null
if "$GATE" --source-root "$FIXTURES/forbidden" --skip-package-check >/dev/null 2>&1; then
    echo "dependency-gate fixture unexpectedly passed" >&2
    exit 1
fi
echo "dependency-gate tests: OK"
