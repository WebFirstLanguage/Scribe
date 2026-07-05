#!/usr/bin/env bash
# Bundle the engine with an example caller and run it.
# Usage: examples/run.sh <example.wfl> [path-to-wfl-binary]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
caller="${1:?usage: examples/run.sh <example.wfl> [wfl-binary]}"
wfl="${2:-wfl}"
out="$here/build/$(basename "${caller%.wfl}").run.wfl"

bash "$here/build/bundle.sh" "$caller" "$out"
exec "$wfl" "$out"
