# Scribe Project Governance

Scribe is the WFL template engine, maintained by Brad / Logbie LLC.
Contributions remain under [Apache-2.0](LICENSE). Preserve existing attribution.

| Document | Purpose |
| --- | --- |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Workflow and commands |
| [testing.md](testing.md) | Test evidence and known limits |
| [SECURITY.md](SECURITY.md) | Private reporting and engine boundaries |
| [CLAUDE.md](CLAUDE.md), [AGENTS.md](AGENTS.md) | Agent entry points |
| [README.md](README.md) | Engine usage |
| [Design](docs/DESIGN.md), [syntax](docs/SYNTAX.md) | Technical contracts |

## Common contribution policy — version 1.0 (2026-09-27)

This version records Brad's approved Logbie LLC governance and subsequent dev
merge and CEO delegations of 2026-09-26. It governs contribution authority;
the repository's technical, compatibility, testing and licensing rules remain
binding. Report substantive conflicts on the owning issue instead of silently
relaxing a rule.

### Branches and review

- Start a short-lived feature, fix or documentation branch from current `dev`;
  open its PR into `dev`. Never push directly to `dev`, `main` or a release
  branch, or force-push shared branches. Promotion is `dev → main` by PR.
- Yomi reviews the current revision against governance and testing policy.
  The PR author, including an agent author, may merge their own PR into `dev`
  only after applicable CI passes on that reviewed revision and findings are
  addressed. This delegation needs no separate per-PR Brad approval.
- Let triggered bot reviews finish; inspect reviews, inline comments and
  discussions. Fix actionable findings or record a reasoned disposition and
  resolve required discussions. Recheck checks and reviews immediately before
  merging. Material changes require fresh applicable CI and Yomi review.
- The PR owner remains responsible while CI or bot review is pending. Use an
  actual scheduled monitor or event-driven continuation, not a promise to watch.
- Do not bypass protections, use an administrator override, remove a check, or
  rerun a genuine failure merely to manufacture green. Access is not authority.

### Evidence and testing

- Behavior changes start with a test failing for the intended reason, followed
  by implementation and passing evidence. Retain exact commands, revisions,
  results and run links under the repository testing policy.
- GitHub Actions on the current reviewed revision is merge evidence; local
  checks supplement it. Enumerate required jobs and their individual results.
  Missing tools, environment failures, missing/pending checks and skipped,
  cancelled or failed required suites are blocked verification, never passes.
  An aggregate green result cannot stand in for an unrun required suite.
- For prose-only work, record “Behavior tests N/A — documentation only” with
  the reason and relevant documentation, link and policy checks. This does not
  waive required CI. Existing risk classes and stricter technical gates remain.
- Run agent-operated runtime tests on Starnet test VM 136 or 104, never VM 143;
  coordinate risky-test snapshots with Nodoka. Preserve the repository's approved
  GitHub Actions execution environments and record their actual results.

### Promotion, release and production authority

Azusa, CEO of Logbie LLC, may approve and perform builds, releases, merges to
`main`, release promotions, tags and production deployments only when every
required check passed on the exact commit being acted on: none skipped,
missing, pending, flaky or failing. Record the SHA, required-check set and
individual result links, then recheck immediately before acting. A different
SHA or aggregate green is insufficient; a flaky rerun is not a waiver.
Anything short of fully green stops for Brad's explicit authorization.
Yomi's current-revision review and handled bot feedback remain required.

Always Brad's decisions regardless of CI: spending money; deleting data,
agents or repositories; anything touching secrets; VM configuration changes;
and removing or weakening required checks. Release/deploy workflow changes,
organization settings/membership and deletion of branches, rulesets or
workflows also require Brad's explicit approval through the owning issue.

Production hosts are read-only for agents: authorized config/log inspection
only, without exposing secrets. No edits, restarts, installs or migrations.
The conditional CEO production-deployment authority above is limited to the
authorized deployment; it grants no general production administration.
Other production changes go to Brad through Azusa.

### Credentials, exceptions and enforcement

Never commit, print, log or paste credentials into files, comments, PRs,
command arguments or remote URLs. Inject authorized tokens through environment
variables from approved storage, with minimal scope. Suspected exposure:
stop propagation, report safe metadata, and coordinate response with Brad.
Do not borrow another agent's or a human's credentials.

Tie governed changes to an owning issue. Record exceptions with scope, reason,
risk, owner, expiry and follow-up, and obtain Brad's explicit approval before
acting. A deviation note is not approval and cannot silently amend policy.

Policy text does not configure GitHub. Verify effective protections and actual
required checks via the API. Report missing controls, identities and platform
limits explicitly; never call a convention machine-enforced. In particular,
a shared author identity cannot supply independent GitHub approval. Deferred
identity enforcement does not authorize bypass or replace Yomi's review.

## Project-specific policy

Preserve HTML auto-escaping, explicit trusted raw output, template syntax and
existing callers. Scribe does not sandbox the filesystem; trusted template
paths and bounded nesting remain security contracts. Changes need tests and
updated technical documentation. Do not add a runtime dependency or language
change as part of governance work.

AI assistance is welcome under the same quality and licensing bar; authors
remain accountable and must not expose private data. Treat contributors with
respect and report conduct concerns privately to info@logbie.com.
Brad resolves technical/governance disputes and approves policy amendments.
