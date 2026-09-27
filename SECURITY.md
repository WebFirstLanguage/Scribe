# Scribe security

Report suspected vulnerabilities privately to info@logbie.com with subject
“Scribe Security Vulnerability”; do not publish exploit details or credentials.
Include affected Scribe/WFL revisions and a sanitized reproduction. No response
SLA or supported-release matrix is claimed. Brad coordinates response.

Preserve HTML auto-escaping and explicit trusted `raw` output. Template source
is trusted code, and include/import/inheritance paths are not a filesystem
sandbox. See [syntax](docs/SYNTAX.md) and [design](docs/DESIGN.md).
Security-boundary changes need negative tests under [testing.md](testing.md).

No credentials in files, logs, PRs or comments. Use approved environment
injection; anything touching secrets is Brad’s decision. Production is
read-only except the explicitly authorized CEO deployment gate in
[GOVERNANCE.md](GOVERNANCE.md).
