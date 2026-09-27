# Scribe agent instructions

Read [GOVERNANCE.md](GOVERNANCE.md), [CONTRIBUTING.md](CONTRIBUTING.md),
[testing.md](testing.md), [SECURITY.md](SECURITY.md), [README.md](README.md),
[design](docs/DESIGN.md) and [syntax](docs/SYNTAX.md) before changes.

Use your own feature branch → `dev`; no direct dev/main pushes. Yomi reviews
the current revision; enumerate exact-SHA Actions results, resolve bot
feedback and keep an actual monitor while processing is pending. Never
bypass controls. Main/release/tag/deploy authority belongs to Azusa only at
the fully-green gate, otherwise Brad; reserved decisions stay with Brad.

Preserve the single-file engine and include-based API, HTML auto-escaping,
trusted raw output and filesystem limitations. No unrelated refactoring.
Test behavior first with the commands in CONTRIBUTING.md. Keep fixtures
disposable, secrets out of output and production hosts read-only.
