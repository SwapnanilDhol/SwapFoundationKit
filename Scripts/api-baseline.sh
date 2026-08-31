#!/bin/bash
#
# api-baseline.sh — deterministic public API surface inventory for SwapFoundationKit.
#
# APPROACH (real symbol graph, not grep):
#   This script builds each first-party library scheme with
#   `-emit-symbol-graph -emit-symbol-graph-dir <dir>` via xcodebuild
#   (representative arm64 iOS Simulator destination, matching the project's working build gate:
#   `xcodebuild -scheme SwapFoundationKit -destination 'generic/platform=iOS
#   Simulator' -configuration Debug ARCHS=arm64 ONLY_ACTIVE_ARCH=YES
#   CODE_SIGNING_ALLOWED=NO build`), then
#   parses the emitted SymbolGraph JSON with python3.
#
#   A symbol is counted as part of the public surface iff:
#     - accessLevel is "public" or "open", AND
#     - the symbol carries a `location` (i.e. it has an explicit source
#       declaration in this repository, under Sources/).
#
#   The `location` requirement is what makes this trustworthy: swift's
#   symbol-graph emission includes tens of thousands of compiler-synthesized
#   / protocol-witness entries with NO location (e.g. `Hashable.hash(into:)`
#   synthesis, `ViewModifier`/`Animatable` boilerplate like `body(content:)`,
#   `concat(_:)`, `transaction(_:)`, `animation(_:)` picked up on every
#   SwiftUI-conforming type). On this codebase that noise alone is ~31,000
#   extra "symbols" with no location — including it would make the count
#   meaningless. Filtering to symbols with a location leaves only things
#   this package's authors actually wrote and marked public.
#
#   Symbol-graph output also files a module's `public extension Foo { … }`
#   blocks on *other* modules' types (e.g. `String`, `Date`, `URL`) into
#   separate `<Module>@<OtherModule>.symbols.json` files. Those are included
#   too, because they are still public declarations owned by this package
#   (this is most of what lives under Sources/SwapFoundationKit/Extensions/).
#
# WHAT THIS UNDER/OVER-COUNTS relative to a naive `grep -c "public "`:
#   - Over-counts vs. grep: every enum case, every stored/computed property,
#     and every declaration on a multi-declaration line becomes its own
#     symbol-graph entry, where grep-by-line would under-count those.
#   - Under-counts vs. a naive grep: doc-comment text and commented-out code
#     containing the word "public" are never included, because they were
#     never compiled.
#   - Neither approach: a symbol-graph "type" count deliberately excludes
#     compiler-synthesized conformance witnesses; a type count from grepping
#     `public (class|struct|enum|protocol)` would roughly agree with the
#     top-level-type numbers here (this script's `UI` domain top-level type
#     count of 92 matches the grep-level baseline recorded in the v4 ledger
#     exactly), but per-declaration counts will differ by design.
#
#   In short: treat the numbers in this file as *this script's* authoritative,
#   reproducible measurement, not as a reconciliation with any older
#   grep-based count. Where the refactoring plan or migration guide cite
#   different totals, this baseline supersedes them (see
#   Docs/development/v4-api-ledger.md, "known gaps").
#
# OUTPUT:
#   Docs/development/api-baseline.txt — a stable, sorted, diffable artifact:
#     - a SUMMARY section (per-target declaration/type counts, per-domain
#       breakdown for the default SwapFoundationKit target);
#     - a SYMBOLS section (one line per public, located declaration:
#       target | kind | file | line | symbol path).
#   No timestamps or machine-specific paths are written. Output is byte-stable
#   for an unchanged tree only when Xcode/SDK/SwiftPM configuration is held
#   constant; symbol-graph inventories can legitimately differ across
#   toolchains. This report is not an ABI or full source-compatibility checker:
#   it does not encode declaration signatures, defaults, availability, or
#   compiler settings.
#
# USAGE:
#   bash Scripts/api-baseline.sh            # regenerate Docs/development/api-baseline.txt
#   bash Scripts/api-baseline.sh --check     # regenerate to a temp file and diff against
#                                             # the committed baseline; exits 1 and prints
#                                             # the diff if they differ (CI gate mode).
#   bash Scripts/api-baseline.sh --skip-build --symbol-graph-dir <dir>
#                                             # reuse a previously emitted symbol-graph
#                                             # directory instead of rebuilding (fast local
#                                             # iteration on the parser only; do not use
#                                             # this mode to produce a committed baseline).
#   bash Scripts/api-baseline.sh --derived-data-path <dir>
#                                             # use an existing DerivedData checkout (useful
#                                             # when a private build would exceed local disk).
#
# REQUIREMENTS: Xcode (xcodebuild), python3. Both are present on macOS CI
# runners and on the dev machine this was authored/tested on (Xcode 26.6).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASELINE_FILE="$REPO_ROOT/Docs/development/api-baseline.txt"

# First-party library schemes to inventory. Deliberately excludes the host
# app scheme (SwapFoundationKitHost) and third-party vendor schemes.
TARGETS=(
  SwapFoundationKit
  SwapFoundationKitNetworking
  SwapFoundationKitAuthentication
  SwapFoundationKitSync
  SwapFoundationKitMedia
  SwapFoundationKitCurrency
  SwapFoundationKitRemoteAI
  SwapFoundationKitFirebase
  SwapFoundationKitFeedback
  SwapFoundationKitGoogleMobileAds
  SwapFoundationKitPulse
  SwapFoundationKitToast
)

MODE="write"
SKIP_BUILD="0"
SYMBOL_GRAPH_DIR=""
DERIVED_DATA_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      MODE="check"
      shift
      ;;
    --skip-build)
      SKIP_BUILD="1"
      shift
      ;;
    --symbol-graph-dir)
      SYMBOL_GRAPH_DIR="$2"
      shift 2
      ;;
    --derived-data-path)
      DERIVED_DATA_PATH="$2"
      shift 2
      ;;
    -h|--help)
      grep -E '^# ?' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# A single mktemp -d call for everything this run needs (build logs,
# generated report, private DerivedData, and — unless overridden — the
# symbol-graph output). Deliberately avoids repeated file-form `mktemp`
# calls with dotted suffixes: on this project's CI/dev sandboxing that
# pattern has been observed to intermittently fail (mkstemp EEXIST on a
# literal, unsubstituted template name) across multiple unrelated scripts.
# A single directory-form `mktemp -d` up front has proven reliable.
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfk-api-baseline.XXXXXX")"
CLEANUP_SYMBOL_GRAPH_DIR="0"

if [[ -z "$SYMBOL_GRAPH_DIR" ]]; then
  SYMBOL_GRAPH_DIR="$WORK_DIR/symgraph"
  mkdir -p "$SYMBOL_GRAPH_DIR"
else
  mkdir -p "$SYMBOL_GRAPH_DIR"
fi

trap 'rm -rf "$WORK_DIR"' EXIT

if [[ "$SKIP_BUILD" == "0" ]]; then
  # Use a private DerivedData path rather than Xcode's shared default. This
  # script may run while other xcodebuild invocations (host build, other
  # agents/CI jobs) are touching the same repo checkout; a shared DerivedData
  # build database will lock and fail with "database is locked" under
  # concurrent builds. A dedicated path avoids that contention entirely.
  if [[ -z "$DERIVED_DATA_PATH" ]]; then
    PRIVATE_DERIVED_DATA="$WORK_DIR/derived"
    mkdir -p "$PRIVATE_DERIVED_DATA"
  else
    PRIVATE_DERIVED_DATA="$DERIVED_DATA_PATH"
    mkdir -p "$PRIVATE_DERIVED_DATA"
    echo "api-baseline: using caller-provided DerivedData at $PRIVATE_DERIVED_DATA (not cleaned)" >&2
  fi
  echo "api-baseline: emitting symbol graphs to $SYMBOL_GRAPH_DIR" >&2
  echo "api-baseline: using DerivedData at $PRIVATE_DERIVED_DATA" >&2
  for scheme in "${TARGETS[@]}"; do
    echo "api-baseline: building scheme $scheme ..." >&2
    LOG_FILE="$WORK_DIR/build-$scheme.log"
    if ! xcodebuild \
        -scheme "$scheme" \
        -destination 'generic/platform=iOS Simulator' \
        -configuration Debug \
        -derivedDataPath "$PRIVATE_DERIVED_DATA" \
        ARCHS=arm64 \
        ONLY_ACTIVE_ARCH=YES \
        CODE_SIGNING_ALLOWED=NO \
        OTHER_SWIFT_FLAGS="-emit-symbol-graph -emit-symbol-graph-dir $SYMBOL_GRAPH_DIR" \
        build > "$LOG_FILE" 2>&1; then
      echo "api-baseline: BUILD FAILED for scheme $scheme; see $LOG_FILE" >&2
      tail -n 80 "$LOG_FILE" >&2
      exit 1
    fi
  done
else
  echo "api-baseline: --skip-build set, reusing symbol graphs in $SYMBOL_GRAPH_DIR" >&2
fi

GENERATED_FILE="$WORK_DIR/generated.txt"

REPO_ROOT="$REPO_ROOT" SYMBOL_GRAPH_DIR="$SYMBOL_GRAPH_DIR" TARGETS="${TARGETS[*]}" \
  python3 "$SCRIPT_DIR/api-baseline-parse.py" > "$GENERATED_FILE"

if [[ "$MODE" == "check" ]]; then
  if [[ ! -f "$BASELINE_FILE" ]]; then
    echo "api-baseline: no committed baseline at $BASELINE_FILE" >&2
    exit 1
  fi
  if diff -u "$BASELINE_FILE" "$GENERATED_FILE" > "$WORK_DIR/diff.txt"; then
    echo "api-baseline: $BASELINE_FILE is up to date." >&2
    exit 0
  else
    echo "api-baseline: $BASELINE_FILE is OUT OF DATE. Run:" >&2
    echo "  bash Scripts/api-baseline.sh" >&2
    echo "and commit the result. Diff:" >&2
    cat "$WORK_DIR/diff.txt" >&2
    exit 1
  fi
else
  mkdir -p "$(dirname "$BASELINE_FILE")"
  cp "$GENERATED_FILE" "$BASELINE_FILE"
  echo "api-baseline: wrote $BASELINE_FILE" >&2
fi
