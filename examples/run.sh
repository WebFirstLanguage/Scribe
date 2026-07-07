#!/usr/bin/env bash
# Run a Scribe example. Examples pull in the engine with `include from`, so no
# build step is needed. We cd to the repo root so relative template paths (used
# by the inheritance example) resolve.
#
# Usage: examples/run.sh <example.wfl> [path-to-wfl-binary]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
caller="${1:?usage: examples/run.sh <example.wfl> [wfl-binary]}"
wfl="${2:-wfl}"
# Normalize the caller to a repo-relative path, then run from the repo root.
caller_abs="$(cd "$(dirname "$caller")" && pwd)/$(basename "$caller")"
cd "$here"
exec "$wfl" "${caller_abs#"$here/"}"
