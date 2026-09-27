# Scribe testing policy and profile

Version 1.0, reviewed 2026-09-27. Owner: Brad / Logbie LLC.
Authority and evidence gates: [GOVERNANCE.md](GOVERNANCE.md).

Behavior changes require an intended failing regression before implementation,
then passing tests on the affected boundaries. Record base/failing/final SHAs,
commands, runtime version, environment, results and exact-commit Actions links.
No retries, skipped required suites or aggregate green may hide a failure.

Run `bash tests/run.sh /absolute/path/to/wfl` from a disposable checkout.
It invokes `wfl --test tests/scribe.test.wfl`; fixtures write into `build/`.
Run the examples in [CONTRIBUTING.md](CONTRIBUTING.md) when affected and compare
rendered output with the corresponding `.expected.html` files. No external
credentials or production data are needed.

Prose-only work is R0: behavior tests N/A with a reason, plus relevant link,
Markdown and policy checks. Engine/API changes are at least R2; security,
untrusted input, escaping, paths and nesting are R3 and need negative cases
and independent review. Preserve include/inheritance/macro behavior, escaping,
raw-output trust and bounded nesting. Real file access needs real fixture tests.

Required Actions contexts are `Documentation checks` and `Scribe tests`.
The proposed CI workflow in PR 4 is still unmerged as of this profile date;
verify that the PR actually runs both contexts before claiming a pass.
Linux CI runtime results do not establish Windows/macOS or production support.
Agent-operated runtime tests use Starnet VM 136/104, never VM 143.

Known gaps: no measured coverage threshold, performance budget, supported
platform matrix or comprehensive release-candidate gate. Brad owns these gaps;
review before the next affected change/release. Browser/a11y testing is N/A
for engine-only prose, but rendered application changes need their app checks.
Missing evidence stays blocked; exceptions require Brad under GOVERNANCE.md.
Retain sanitized CI and review evidence with the PR.
