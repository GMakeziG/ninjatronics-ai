# Assignment

## Assignment ID

`PH1-SEN-002`

## Owner

Codex carrying the independent Sentinel reviewer role.

## Requested by

Pi acting as the active orchestrator (Nova role), with Gerso approval on 2026-08-23.

## Priority

High.

## Objective

Perform a bounded, independent, read-only security review of the integrated Wave 1 security-relevant artifacts and return control-by-control findings without modifying controls or granting release approval.

## Context

PH1-ARC-001, PH1-CLD-002, PH1-SHI-001, and PH1-SEN-001 are integrated into `/home/gerso/Development/zaifu` `master`. PH1-SEN-001 was authored by Claude Code carrying the Sentinel policy-author role and integrated as `0cc5741`. Persisted transport and validation evidence confirms Codex did not contribute to the reviewed artifacts and remains independent. This assignment is not WP-15 and cannot approve release.

## Scope

Read-only review of:

- PH1-ARC-001 security-document edits and reconciliation evidence.
- PH1-CLD-002 repository/CI controls and explicit hosted-control gaps.
- PH1-SHI-001 platform-design security controls and retained G5 decisions.
- PH1-SEN-001 Mode A trust-boundary policy, deny-by-default egress schema, and narrow threat-model/security-architecture edits.

Assess security-document correctness, control completeness and internal consistency, deny-by-default behavior, traceability, evidence quality, documented gaps, and whether remediation/re-review is required.

## Out of scope

- Any file, repository, control, policy, schema, CI, platform, infrastructure, or documentation modification.
- Release approval, WP-15 substitution, Mode B authorization, provider selection/calls, production-data access/egress, cloud/resource/spend action, or deployment.
- Resolving G2 or the 70% trust-ceiling/answer-threshold question.
- Using or attempting Hermes.

## Inputs

- Zaifu integrated `master`, especially the artifacts and project-local handoffs for PH1-ARC-001, PH1-CLD-002, PH1-SHI-001, and PH1-SEN-001.
- Central evidence under `shared/handoffs/PH1-ARC-001/`, `PH1-CLD-002/`, `PH1-SHI-001/`, and `PH1-SEN-001/` in `/home/gerso/Development/ninjatronics-ai`.
- `distributions/sentinel/README.md` and `shared/standards/agent-routing.md`.
- Planning scope in `shared/handoffs/PH1-CLD-001/first-wave-proposal.md` and `tranche-1-results.md`.

## Graphify context

The orchestrator ran: `graphify query "Zaifu persisted state after PH1-SEN-001, next assignments PH1-SEN-002 and PH1-COD-001, runtime routing and independent review"`. It identified the persisted Tranche 2 proposal and assignment ledger. Treat Graphify only as navigation; verify conclusions against source and evidence files.

## Constraints

- Strictly read-only. Do not create, edit, delete, stage, commit, or format any file in either repository.
- Do not invoke another agent or runtime.
- Do not use Hermes under any circumstances.
- Preserve independent-review boundaries and explicitly state Codex's eligibility.
- Use targeted reads/searches; do not regenerate Phase 1 planning.
- Report findings with severity: BLOCKER, HIGH, MEDIUM, LOW, or NOTE.

## Required deliverables

Return in the Codex response only:

1. Overall bounded-review verdict: PASS, PASS WITH FINDINGS, REMEDIATION REQUIRED, or BLOCK.
2. Runtime identity and independence/eligibility statement.
3. Control-by-control verdict matrix covering each scoped artifact/control family.
4. Findings with severity, exact file/line or commit evidence, impact, and required remediation.
5. Explicit re-review conditions.
6. Explicit statement that this review is not WP-15 and grants no release approval.
7. Commands/checks performed and confirmation that no files changed.

## Validation required

- Verify repository status remains unchanged.
- Validate material security conclusions directly against authoritative files.
- Inspect the PH1-SEN-001 schema for closed-object/deny-by-default behavior and consistency with Mode A/Mode B-disabled policy.
- Distinguish unavailable hosted controls from falsely claimed implemented controls.
- Confirm no review conclusion silently closes an open human or financial gate.

## Evidence required

Exact paths/line references, relevant commit references, commands/checks, control verdicts, severity, remediation and re-review requirements, and clean read-only status confirmation.

## Dependencies

All four reviewed assignments are integrated. Gerso approved this dispatch. Codex independence was reconfirmed immediately before dispatch from persisted evidence and unchanged live Codex state.

## Escalation conditions

Return BLOCK or REMEDIATION REQUIRED if a BLOCKER/HIGH issue exists, evidence is insufficient for a scoped control, independence is compromised, or safe review requires modification or prohibited access.

## Completion criteria

Every scoped control family has an evidence-backed verdict; all findings are severity-ranked; remediation/re-review conditions are explicit; independence and non-release scope are stated; and no file changed.

## Recommended next owner

Active orchestrator for independent validation, persistence, and next-work reassessment.
