#!/usr/bin/env bash
# bundle.sh — produce a runnable WFL program from the Scribe engine + a caller script.
#
# WFL's `load module` does not expose a module's actions to the static analyzer,
# so multi-file programs that share actions fail analysis. As a work-around we
# concatenate the engine source with a caller script into a single file.
#
# Usage:
#   build/bundle.sh <caller.wfl> <output.wfl>
#   build/bundle.sh <caller.wfl>            # prints to stdout
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
engine="$here/src/scribe.wfl"
caller="${1:?usage: bundle.sh <caller.wfl> [output.wfl]}"
out="${2:-}"

bundle() {
    cat "$engine"
    printf '\n// ===== bundled caller: %s =====\n' "$caller"
    cat "$caller"
}

if [[ -n "$out" ]]; then
    bundle > "$out"
else
    bundle
fi
