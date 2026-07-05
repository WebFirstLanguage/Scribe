#!/usr/bin/env bash
# Bundle the engine with the test suite and run it under `wfl --test`.
#
# Usage: tests/run.sh [path-to-wfl-binary]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wfl="${1:-wfl}"
bundle="$here/build/scribe.test.bundle.wfl"

bash "$here/build/bundle.sh" "$here/tests/scribe.test.wfl" "$bundle"
exec "$wfl" --test "$bundle"
