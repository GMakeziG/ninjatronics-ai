# Assignment

## Assignment ID

`PH1-SHI-001`

## Owner

Shinobi role executed by Claude Code as the approved fallback. Native Shinobi is not in the validated specialist dispatcher allow-list. Preserve Shinobi infrastructure, operations, rollback, evidence, and security-review rules.

## Requested by

Pi acting as active orchestrator (Nova role)

## Priority

High

## Objective

Produce WP-14's design-only platform architecture and cost/region/data-residency proposal without creating or changing any cloud or deployment resource.

## Context

Gerso approved Wave 1 Tranche 1 dispatch on 2026-08-23 but explicitly did not approve G5. No cloud resource creation, deployment, credentials, DNS change, or spending is authorized. The target concepts are Azure and Vercel, but exact region/residency and spend remain owner decisions after this proposal.

## Scope

Repository: `/home/gerso/Development/zaifu`, isolated assignment worktree/branch.

Exclusive implementation ownership is limited to these new files:

- `docs/platform/PHASE_1_PLATFORM_ARCHITECTURE.md`
- `docs/platform/PHASE_1_COST_RESIDENCY_PROPOSAL.md`
- `docs/orchestration/assignments/PH1-SHI-001.md`
- `docs/orchestration/handoffs/PH1-SHI-001.md`

Design topics:

- Azure/Vercel topology and environment boundaries.
- GitHub Actions OIDC and managed-secret design with no stored cloud credentials.
- Encryption/key separation, backup/restore, rollback/recovery, RPO/RTO proposals.
- Network exposure/egress, observability, auditability, supply-chain controls.
- Costed Azure region and data-residency options with assumptions, alternatives, uncertainty, and decision criteria.
- Interfaces to the WP-01 workspace at a conceptual level only. Do not finalize assumptions that require PH1-CLD-002 output; identify them as integration checkpoints and, if its handoff becomes available, verify against it before completion.

## Out of scope

- Any existing file modification beyond the four exact new files above.
- IaC, Terraform/Bicep, deploy workflow, application code, CI workflow, cloud configuration, provider account access, credentials, API calls that create/change resources, Azure/Vercel resource creation, deployment, DNS, spend, purchase, reservation, production action, or destructive action.
- Selecting a final paid plan or region on Gerso's behalf.
- Claiming controls are deployed or tested. This is design evidence only.
- Security self-approval.

## Inputs

- `shared/handoffs/PH1-CLD-001/result.md` WP-14 and platform/security matrices.
- `shared/handoffs/PH1-CLD-001/validation.md`, `routing-reassessment.md`, and `first-wave-proposal.md`.
- Zaifu ADR-012, ADR-013, ADR-023, ADR-024, security architecture, threat model, and data classification.
- Current public Azure/Vercel documentation and pricing sources, with access date and explicit estimation assumptions. Do not authenticate to provider consoles.

## Graphify context

- Command run: `graphify query "What are PH1-ARC-001 PH1-CLD-002 PH1-SHI-001, their work packages, dependencies, file ownership boundaries, handoff requirements, and Wave 1 integration order?"`
- It identified WP-14 and Shinobi ownership sources. Verify against authoritative Zaifu documents and public provider sources; graph output is only navigation.

## Constraints

- Strictly design/documentation only in the assigned worktree and branch.
- Stay within the four exact owned files. Stop before editing any other path.
- Never access credentials or authenticated cloud consoles.
- Clearly label estimates, assumptions, unknowns, and items requiring Gerso/Sentinel decisions.
- Every architecture control must distinguish proposed, locally verifiable later, and provider-dependent evidence.
- Commit the bounded change. Do not merge, push, or alter another branch/worktree.
- Keep Codex unused.

## Required deliverables

- Platform architecture document with diagrams in text/Mermaid, trust/environment boundaries, OIDC/secrets, encryption, backup/restore, observability, network, supply-chain, rollback/recovery, and future validation plan.
- Cost/residency options table with at least two viable Azure region/topology alternatives, source links/access dates, assumptions, monthly cost ranges, tradeoffs, and recommendation subject to G5.
- Explicit no-resource/no-deployment/no-credential/no-DNS/no-spend attestation.
- Project-local assignment and handoff in the exact paths above.
- Concise final response with commit SHA and handoff path.

## Validation required

- Source/link check and arithmetic cross-check for estimates.
- Requirements traceability to Zaifu security/architecture sources.
- Check all language avoids implying deployed controls.
- `git diff --check`, exact four-file boundary check, and clean status after commit.
- Verify no cloud CLI/auth/resource/deployment commands were run.

## Evidence required

Research source list with access dates, calculation method, changed-file list, commit SHA, validation commands/results, interface assumptions/checkpoints, and explicit prohibited-action attestation.

## Dependencies

May start alongside PH1-CLD-002 for discovery. Final application-interface assumptions must be verified after PH1-CLD-002 returns or left explicitly pending for orchestrator integration. G5 remains closed.

## Escalation conditions

Any action would require credentials, authenticated console access, resources, spend, DNS, deployment, or irreversible change; provider pricing/residency evidence cannot support a bounded recommendation; Zaifu source conflict changes security or data-residency requirements.

## Completion criteria

The four owned design/evidence files exist, are source-traceable, contain no claim of deployment, and present decision-ready options while preserving G5; commit is ready for orchestrator validation.

## Recommended next owner

Active orchestrator for independent validation and interface reconciliation, then PH1-SEN-002 for architecture security review when authorized, and Gerso for later G5 decision.
