# Contributing to Scribe

Read [GOVERNANCE.md](GOVERNANCE.md), [testing.md](testing.md),
[SECURITY.md](SECURITY.md), [design](docs/DESIGN.md) and [syntax](docs/SYNTAX.md).
Create your own feature branch from current `dev`; open a PR into `dev`.
Use a conventional subject such as `docs: clarify contribution policy`.
Use the [PR template](.github/pull_request_template.md), record actual results,
and wait for current-revision Yomi review and required CI before a dev merge.
Main/release/deploy actions follow the conditional CEO gate in GOVERNANCE.md.

## Commands from the repository root

- `bash tests/run.sh /absolute/path/to/wfl`: engine regression suite.
- `bash examples/run.sh examples/blog.wfl /absolute/path/to/wfl`: blog example.
- `bash examples/run.sh examples/inheritance.wfl /absolute/path/to/wfl`: inheritance example.
- `bash examples/run.sh examples/theme.wfl /absolute/path/to/wfl`: theme example.

Record the runtime version and source revision. Use disposable fixtures;
`build/` contains test output. No engine build step is needed.
Behavior fixes need intended failing evidence before implementation.
Prose-only changes use relevant link/policy checks; required CI is not waived.
Preserve Apache-2.0 and third-party attribution; do not change licensing.
