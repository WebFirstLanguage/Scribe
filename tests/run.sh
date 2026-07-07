#!/usr/bin/env bash
# Run the Scribe test suite. The suite pulls in the engine with `include from`,
# so no build step is needed. Run from anywhere; we cd to the repo root so the
# build/ fixture paths resolve.
#
# Usage: tests/run.sh [path-to-wfl-binary]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wfl="${1:-wfl}"
mkdir -p "$here/build"
cd "$here"
exec "$wfl" --test tests/scribe.test.wfl
