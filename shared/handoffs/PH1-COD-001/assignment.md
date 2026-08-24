# Assignment

## Assignment ID

`PH1-COD-001`

## Owner

Codex carrying the independent Ledger reviewer role.

## Requested by

Pi acting as the active orchestrator (Nova role), with Gerso approval on 2026-08-23.

## Priority

High.

## Objective

Perform a bounded, independent, read-only value-fidelity review of PH1-SEN-001 and determine whether the Mode A trust-boundary policy preserves authoritative financial-engine values and future token-substitution fidelity.

## Context

PH1-SEN-001 was authored by Claude Code carrying the Sentinel policy-author role and integrated into `/home/gerso/Development/zaifu` `master` as `0cc5741`. Persisted evidence confirms Codex did not implement or modify PH1-SEN-001 or any reviewed financial/value-fidelity control. G2 remains open, Mode B remains disabled, and the 70% trust-ceiling/answer-threshold issue belongs to WP-03/G2.

## Scope

Read-only verification that:

- Deterministic explanations cannot alter, round, infer, reinterpret, or replace authoritative engine values.
- Provider abstraction is never a calculation source.
- Future token substitution and rehydration requirements preserve exact numeric fidelity, including integer-minor-unit values and exact engine outputs.
- The policy/schema trace correctly to authoritative engine and explainability sources without inventing financial semantics.

## Out of scope

- Modifying financial rules, engines, fixtures, policy, schema, documentation, or any repository file.
- Resolving the 70% trust-ceiling/answer-threshold question, changing confidence bands, or closing G2.
- Mode B enablement, provider selection/calls, production-data access/egress, cloud/resource/spend action, deployment, or release approval.
- Using or attempting Hermes.

## Inputs

- Zaifu integrated PH1-SEN-001 artifacts: `docs/security/LLM_TRUST_BOUNDARY.md`, `docs/security/llm-egress-allowlist.schema.json`, narrow security cross-references, and project-local PH1-SEN-001 handoff.
- Authoritative Zaifu engine/value and explainability documentation cited by PH1-SEN-001, including `docs/product/FINANCIAL_ENGINE.md`, `EXPLAINABILITY.md`, and `TRUST_MODEL.md` as applicable.
- Central PH1-SEN-001 assignment/result/validation evidence under `/home/gerso/Development/ninjatronics-ai/shared/handoffs/PH1-SEN-001/`.
- Tranche scope in `shared/handoffs/PH1-CLD-001/first-wave-proposal.md` and `tranche-1-results.md`.

## Graphify context

The orchestrator ran: `graphify query "Zaifu persisted state after PH1-SEN-001, next assignments PH1-SEN-002 and PH1-COD-001, runtime routing and independent review"`. It identified the persisted read-only Ledger review scope. Treat Graphify only as navigation; verify against authoritative source files.

## Constraints

- Strictly read-only. Do not create, edit, delete, stage, commit, or format any file in either repository.
- Do not invoke another agent or runtime.
- Do not use Hermes under any circumstances.
- Do not decide G2 questions or invent a financial rule.
- Use targeted reads/searches; do not regenerate Phase 1 planning.
- Report findings with severity: BLOCKER, HIGH, MEDIUM, LOW, or NOTE.

## Required deliverables

Return in the Codex response only:

1. Ledger-scope verdict: APPROVE, APPROVE WITH FINDINGS, or BLOCK.
2. Runtime identity and independence/eligibility statement.
3. Value-fidelity invariant checklist with pass/fail and exact evidence.
4. Source-to-policy/schema traceability assessment.
5. Findings with severity, exact file/line evidence, impact, and required remediation.
6. Explicit statement that the review does not resolve the 70% ceiling/answer-threshold issue and does not close G2.
7. Commands/checks performed and confirmation that no files changed.

## Validation required

- Verify repository status remains unchanged.
- Compare policy/schema statements directly with authoritative engine-value and explanation sources.
- Check exact-value preservation, provider non-calculation boundaries, token substitution/rehydration integrity, serialization/rounding prohibitions, and enum/output fidelity.
- Identify but do not resolve source conflicts or open financial gates.

## Evidence required

Exact paths/line references, invariant outcomes, traceability evidence, findings and severity, approve/block rationale, commands/checks, and clean read-only status confirmation.

## Dependencies

PH1-SEN-001 and D-02/G4 Mode A are integrated/approved within their existing bounds. Gerso approved this dispatch. Codex independence was reconfirmed immediately before dispatch from persisted evidence and unchanged live Codex state.

## Escalation conditions

Return BLOCK if a value-fidelity invariant fails, authoritative sources conflict materially, evidence is insufficient, independence is compromised, or safe review requires modification or a G2 decision.

## Completion criteria

Every invariant has an evidence-backed outcome; traceability and findings are explicit; the Ledger verdict is stated; G2 remains open; and no file changed.

## Recommended next owner

Active orchestrator for independent validation, persistence, and next-work reassessment.
