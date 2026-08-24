# Assignment

## Assignment ID

`PH1-SEN-001`

## Owner

Sentinel policy-author role executed by Claude Code. Runtime and specialist role are separate: Claude Code carries the Sentinel security, compliance, risk, deny-by-default, least-privilege, evidence, and residual-risk rules in `distributions/sentinel/README.md`.

## Requested by

Pi acting as active orchestrator (Nova role)

## Priority

High

## Objective

Implement WP-11 as design/documentation only: define the complete Mode A LLM trust-boundary policy and machine-consumable data contract before provider code exists, while preserving authoritative engine values, the approved 70% Phase 1 trust ceiling, and the closed D-02/G4 Mode A decision without changing any financial rule.

## Context

Gerso authorized only PH1-SEN-001 for staged Tranche 2 execution on 2026-08-23. PH1-ARC-001 is integrated. D-02/G4 authorizes Mode A only: deterministic server-side explanations and no external LLM provider call carrying production financial data. Mode B remains disabled and requires a new explicit approval. Phase 1 manual-entry data can reach at most Level 2, User Confirmed (70%); the ceiling-versus-answer-threshold question belongs to WP-03/G2 and must remain unresolved here. This policy cannot approve itself: PH1-SEN-002 and PH1-COD-001 remain undispatched and require separate final approval after integration.

## Scope

Repository: `/home/gerso/Development/zaifu`, isolated assignment worktree and branch based on integrated `master` commit `a24359856d15d011ea19dfee64370fe57d534470`.

Exclusive file ownership:

- `docs/security/LLM_TRUST_BOUNDARY.md` — new authoritative design/policy artifact.
- `docs/security/llm-egress-allowlist.schema.json` — new machine-readable allowlist/data-contract schema directly consumable by future WP-12 work.
- `docs/security/THREAT_MODEL.md` — narrowly scoped cross-reference/refinement only for TM-08, TM-09, TM-10, Mode A, and the new policy/schema; do not perform general reconciliation.
- `docs/security/SECURITY_ARCHITECTURE.md` — narrowly scoped cross-reference only to the new policy/schema and Mode A boundary; do not perform general reconciliation.
- `docs/orchestration/assignments/PH1-SEN-001.md` — exact project-local assignment record.
- `docs/orchestration/handoffs/PH1-SEN-001.md` — exact project-local handoff record.

No other path is owned. Stop and escalate before editing any other file.

The policy/data contract must cover:

- Mode A as the default and only Phase 1 mode, including deterministic degradation behavior.
- Explicit field-level allowlist and deny-by-default treatment for every unenumerated field.
- Tokenization/minimization design for a future, disabled Mode B, without selecting or calling a provider.
- Deterministic explanation boundary and value-fidelity invariants: provider abstraction is never a calculation source; authoritative integer-minor-unit values and exact engine outputs cannot be changed, rounded, inferred, or replaced by prose generation.
- The approved Level 2 / 70% trust ceiling as input metadata/policy context only; do not define an answer threshold, alter confidence bands, or resolve WP-03/G2.
- Mandatory single egress broker, provider abstraction, fail-closed validation, kill switch, audit events, metadata-only logging, tool denial, safe rendering, and Mode B-disabled conditions.
- Provider eligibility prerequisites for any future Mode B as pass/fail requirements: retention, training use, subprocessors, incident notification, deletion, residency, access control, and separate explicit Gerso approval.
- Negative-test and prompt-injection corpus design, including allowlist violations, unmasked numeric/date/identifier leakage, unknown fields, unauthorized tools, kill-switch behavior, substitution integrity, and markup rendered as data.
- Traceability from ADR-023, ADR-003, ADR-007, ADR-013, TM-08, TM-09, TM-10, data classification, security architecture, product explanation requirements, and D-02/G4.

## Out of scope

- Provider selection, recommendation, comparison, research, contract negotiation, account creation, API use, or provider call.
- Any production-data access or egress; credentials, secrets, authenticated consoles, or external data transfer.
- Mode B enablement or any claim that Mode B is approved.
- WP-12 code, provider adapters, broker implementation, application code, tests, schemas outside the owned allowlist schema, infrastructure, CI, deployment, DNS, cloud/resource action, or spend.
- Financial-rule, engine, test-vector, trust-percentage, answer-threshold, confidence-band, affordability, forecast, decision, or calculation changes. G2 remains open.
- General edits to the WP-02 reconciliation, decision log, planning/product/architecture documents, or Tranche 1 artifacts.
- PH1-SEN-002 or PH1-COD-001 dispatch, implementation, or review.

## Inputs

- `shared/handoffs/PH1-CLD-001/result.md`, especially PH1-WP-11 and Section 8.
- `shared/handoffs/PH1-CLD-001/first-wave-proposal.md` and `tranche-1-results.md`.
- Zaifu `docs/planning/DECISION_LOG.md` (ADR-003, ADR-007, ADR-013, ADR-023, ADR-024, Phase 1 Owner Decision Addendum).
- Zaifu `docs/security/DATA_CLASSIFICATION.md`, `SECURITY_ARCHITECTURE.md`, and `THREAT_MODEL.md`.
- Zaifu `docs/product/EXPLAINABILITY.md`, `TRUST_MODEL.md`, and relevant planning requirements.
- Zaifu integrated PH1-ARC-001 assignment/handoff.
- `distributions/sentinel/README.md` for the Sentinel role rules.

## Graphify context

- Exact command: `graphify query "What source documents, decisions, constraints, and exact file ownership define PH1-SEN-001 WP-11 Mode A trust-boundary policy and data contract?"`
- Scoped result identified PH1-WP-11, Section 8, the authoritative baseline, Sentinel ownership, and the Phase 1 plan as primary nodes. The output was broad/truncated, so it is only a navigation lead.
- Verify every security-relevant conclusion against authoritative Zaifu source files. Graphify output is not evidence.

## Constraints

- Work only in the assigned worktree and branch.
- Modify only the six exclusively owned paths listed above.
- Documentation/design only. Do not execute application code or make external/provider calls.
- Do not access production data, credentials, secrets, cloud consoles, resources, or deployment systems.
- Do not use Codex, directly or indirectly; preserve it for independent PH1-SEN-002 and PH1-COD-001 review.
- Do not use Hermes under any circumstances. Claude Code is the sole execution runtime.
- Do not claim independent Sentinel approval. This is Sentinel policy authorship carried by Claude Code and requires later independent Codex review.
- Do not silently resolve a source conflict or open gate. Escalate it with exact citations.
- Avoid adding dependencies. Validate JSON with installed/local standard tooling only.
- Commit the bounded change. Do not merge, push, rewrite history, or alter another branch/worktree.

## Required deliverables

- Complete `LLM_TRUST_BOUNDARY.md` covering the listed policy/control requirements.
- Valid machine-readable `llm-egress-allowlist.schema.json` with explicit allowed fields, denied-by-default behavior, and constraints that encode the design without authorizing Mode B.
- Narrow threat-model and security-architecture cross-references within ownership.
- Project-local assignment and specialist handoff in the exact owned paths.
- A committed bounded result and concise final response containing commit SHA and handoff path.

## Validation required

- Parse the JSON schema successfully with an installed standard JSON parser.
- Demonstrate allowlist completeness and deny-by-default semantics by inspection plus reproducible positive/negative fixture checks that do not require provider or network calls.
- Verify traceability to TM-08, TM-09, TM-10, ADR-023, D-02/G4, data classification, and value-fidelity requirements.
- Search for and report any wording that could imply provider selection, Mode B authorization, production-data egress, financial-rule changes, or implemented controls.
- `git diff --check`, exact changed-file boundary check from the assigned base, and clean status after commit.
- Confirm no provider call, production-data access/egress, financial-rule change, cloud/resource action, deployment, Codex use, or Hermes use occurred.

## Evidence required

- Exact commands and summarized results.
- Changed-file list and diff-stat.
- Source-to-control traceability table.
- Allowlist/deny rules and negative-test design.
- Value-fidelity invariant checklist.
- Open questions, residual risks, Mode B prerequisites, and named approval requirements.
- Before/after Git status, base commit, result commit, and clean worktree evidence.
- Explicit runtime statement: `Claude Code carrying Sentinel policy-author role`; explicit Codex and Hermes non-use statements.

## Dependencies

- PH1-ARC-001 integrated and accepted — satisfied.
- D-02/G4 Mode A approval — satisfied for Mode A only.
- G2/WP-03 financial baseline — intentionally open and not to be changed.

## Escalation conditions

Stop and report before continuing if completion requires an unowned file; a provider choice/call; production data; a financial-rule or trust-threshold decision; Mode B enablement; a credential, cloud/resource, spend, deployment, or external-system action; Codex or Hermes; or a source conflict without clear governing authority.

## Completion criteria

All six owned artifacts are complete and internally consistent; the schema parses and encodes fail-closed behavior; required traceability, invariants, negative tests, risks, and approvals are explicit; only owned paths changed; a clean bounded commit exists; and the handoff accurately records all validation and non-actions. The assignment does not self-approve the security policy or close G2.

## Recommended next owner

Active orchestrator for independent scope/evidence validation and ordered integration. After integration and Codex eligibility reconfirmation, Gerso must separately approve dispatch of PH1-SEN-002 and PH1-COD-001.
