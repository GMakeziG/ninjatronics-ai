# Assignment

## Assignment ID

`PH1-ARC-001`

## Owner

Archivist role executed by Claude Code. This is an intentional approved fallback to conserve native Hermes quota. Preserve all Archivist documentation, traceability, historical-record, and evidence-integrity rules.

## Requested by

Pi acting as active orchestrator (Nova role)

## Priority

High

## Objective

Implement WP-02 by reconciling Zaifu's approved Phase 1 product, planning, and security baseline without rewriting historical decisions.

## Context

Gerso approved Wave 1 Tranche 1 dispatch on 2026-08-23. Binding decisions: upload/import is excluded from Phase 1 and maximum reachable trust is 70%; internal package names are `financial-engine`, `forecast-engine`, and `decision-engine`; ADR-019 supersedes conflicting ADR-002 code naming while ADR-002 engine boundaries remain; MFA is mandatory; Phase 1 uses Mode A only. G2 remains open after reconciliation.

## Scope

Repository: `/home/gerso/Development/zaifu`, isolated assignment worktree/branch.

Exclusive implementation ownership:

- Existing planning/product/security documentation needed to close WP-02 contradictions.
- Exact project-local orchestration files `docs/orchestration/assignments/PH1-ARC-001.md` and `docs/orchestration/handoffs/PH1-ARC-001.md`.

Required reconciliation includes:

- Import exclusion and 70% maximum trust ceiling; reconcile ADR-010 and affected scope, trust, journey, threat/control references.
- MFA-required language under ADR-022.
- ADR-019 internal package names over conflicting ADR-002 code naming while preserving ADR-002 engine boundaries and history.
- Mode A references consistent with the approved D-02/G4 decision.
- Non-financial contradictions assigned to WP-02, including confidence-label wording/bands where source authority permits; unresolved financial rules must be deferred to WP-03 rather than invented.

## Out of scope

- `docs/architecture/FINANCIAL_TEST_VECTORS.md`.
- `docs/architecture/FINANCIAL_ENGINE.md`.
- `docs/security/LLM_TRUST_BOUNDARY.md`.
- `docs/platform/**` (reserved to PH1-SHI-001).
- Root toolchain, `.github/**`, `apps/**`, `packages/**`, code, schema, tests, infrastructure, deployment, cloud actions, credentials, spend, DNS, or production changes.
- Rewriting or deleting dated historical decisions. Add supersession/addenda and current-authority statements instead.
- Claiming Sentinel approval or closing G2.

## Inputs

- `shared/handoffs/PH1-CLD-001/result.md`, especially WP-02 and contradiction register.
- `shared/handoffs/PH1-CLD-001/validation.md`, `routing-reassessment.md`, and `first-wave-proposal.md`.
- Zaifu ADR-022 through ADR-025 and the approved Phase 1 decision addendum.
- Ninjatronics Archivist distribution and orchestration/evidence standards.

## Graphify context

- Command run: `graphify query "What are PH1-ARC-001 PH1-CLD-002 PH1-SHI-001, their work packages, dependencies, file ownership boundaries, handoff requirements, and Wave 1 integration order?"`
- The graph located PH1-CLD-001 planning and ownership sources but was truncated; use it only as navigation.
- Verify all conclusions against authoritative Zaifu source files. Graph output is not evidence.

## Constraints

- Work only in the assigned worktree and branch.
- Stay within exclusive ownership above. If another file is required, stop and request orchestrator approval.
- Do not invent evidence, approvals, validation outcomes, product requirements, or financial rules.
- Preserve source history and explain every correction.
- Commit the bounded change. Do not merge, push, or alter another branch/worktree.
- Keep Codex unused.

## Required deliverables

- Reconciled documentation.
- Contradiction-closure table mapping source conflict, approved authority, files changed, and disposition.
- Rationale for every correction and explicit history-preservation statement.
- Project-local assignment and specialist handoff in the exact paths above.
- Concise final response with commit SHA and handoff path.

## Validation required

- Markdown/internal link check using available repository tooling or a reproducible no-install fallback.
- Targeted searches proving stale optional-MFA, import-in-MVP, conflicting package-name, and Phase 1 Mode B claims are removed or explicitly historical.
- `git diff --check`, changed-file boundary check, and clean status after commit.
- Verify financial-rule files and reserved paths are unchanged.

## Evidence required

Commands and results, changed-file list, commit SHA, contradiction table, link-check result, before/after status, and explicit no-code/no-cloud/no-resource/no-spend statement.

## Dependencies

G1, D-05, DO-06, and D-02/G4 Mode A are satisfied. G2 remains pending.

## Escalation conditions

Conflicting approved authorities; any needed financial-rule change; any need to edit excluded/reserved paths; security baseline ambiguity; evidence that an approved historical decision would need deletion or rewriting.

## Completion criteria

All bounded WP-02 contradictions are closed or explicitly deferred with owners; deliverables and evidence exist; only owned files changed; commit is ready for orchestrator validation.

## Recommended next owner

Active orchestrator for independent validation and integration, then PH1-SEN-002 for security-document review when authorized.
