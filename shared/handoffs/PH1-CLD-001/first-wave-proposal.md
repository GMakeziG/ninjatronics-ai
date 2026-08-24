# Zaifu Phase 1 — Proposed Wave 1 Assignments

**Date:** 2026-08-23
**Status:** Ready for Gerso dispatch approval; not dispatched
**Basis:** PH1-CLD-001 plan, Pi validation, approved routing reassessment, G1, D-05, DO-06, D-02/G4 Mode A, and D-04 design-only treatment.

## Readiness conclusion

Wave 1 is ready for staged dispatch. G2 is a post-reconciliation gate and does not block these bounded scopes. D-01/G3, D-03, D-06, and D-07/G6 are later gates. G5 remains closed; WP-14 is strictly design-only.

## Proposed assignments

### PH1-ARC-001 — WP-02 authoritative baseline reconciliation

- **Specialist role:** Archivist, with Sentinel ownership limited to security-document approval.
- **Selected runtime:** Native Hermes Archivist.
- **Approved fallback:** Claude Code carrying Archivist rules if native Archivist is unavailable, quota-constrained, or uneconomical. Fallback must be disclosed.
- **Mode:** Documentation implementation in an isolated Git worktree.
- **Dependencies satisfied:** G1, D-05, DO-06, D-02/G4 Mode A.
- **Scope:** Reconcile the approved import exclusion and 70% trust ceiling; make ADR-019 authoritative over conflicting ADR-002 code naming while preserving ADR-002 engine boundaries; reconcile MFA baseline language; align Mode A references; close the non-financial contradictions assigned to WP-02; preserve dated historical decisions.
- **File ownership:** Zaifu planning, product, and security documentation assigned by WP-02. It must not edit financial rules/test vectors or Wave 1 code/configuration files.
- **Required evidence:** contradiction-closure table, link check, changed-file list, rationale for each correction, and explicit preservation of history.
- **Review:** Nova; PH1-SEN-002 for security-document changes.
- **Human gate after work:** G2 remains open; WP-02 output contributes to it.

### PH1-CLD-002 — WP-01 monorepo foundation and toolchain

- **Specialist role:** Forge.
- **Selected runtime:** Claude Code.
- **Approved fallback:** Codex only after the workspace/layout design is fixed; fallback must not later approve its own repository security controls.
- **Mode:** Implementation in a separate Git worktree.
- **Dependencies satisfied:** G1 and DO-06.
- **Scope:** Create the pnpm/TypeScript workspace, CI validation foundation, and internal packages named `financial-engine`, `forecast-engine`, and `decision-engine`. No engine, schema, feature, deployment, or cloud-resource implementation.
- **File ownership:** Root workspace/toolchain files, `.github/workflows/ci.yml`, and empty application/package scaffolding. Documentation reconciliation remains PH1-ARC-001 ownership; overlapping files require orchestrator integration rather than concurrent edits.
- **Required evidence:** clean-checkout install, lint/typecheck/test results, workspace acyclicity, strict TypeScript checks, changed-file list, and CI configuration evidence. Repository settings that cannot be changed locally are reported, not fabricated.
- **Review:** Nova; PH1-SEN-002 for secret-scanning, branch-protection, and CI permission controls.
- **Human gate after work:** G2 naming condition is satisfied by DO-06; G2 baseline approval still remains open.

### PH1-SHI-001 — WP-14 platform architecture and cost/residency proposal

- **Specialist role:** Shinobi.
- **Selected runtime:** Claude Code carrying Shinobi rules as the approved fallback.
- **Fallback reason:** Native Shinobi is not in the validated specialist dispatcher allow-list; the task is broad design work; no native runtime failure is required before using this already-approved fallback.
- **Mode:** Design/documentation only in a separate Git worktree.
- **Dependencies:** May start alongside PH1-CLD-002 for architecture discovery. It may not finalize application interface assumptions until PH1-CLD-002 returns.
- **Scope:** Azure/Vercel topology, environment boundaries, OIDC/secret handling design, encryption/backup/restore design, observability design, and a costed Azure region/data-residency proposal with alternatives and assumptions.
- **Prohibited actions:** No Terraform apply, Azure/Vercel resource creation, credential use, cloud spending, deployment, DNS changes, or production action.
- **File ownership:** New platform architecture/cost proposal documents only. No application code, CI workflow, live IaC, or cloud configuration.
- **Required evidence:** options table, cost assumptions, region/residency tradeoffs, proposed rollback/recovery approach, source references, and explicit no-resource/no-spend statement.
- **Review:** Nova; PH1-SEN-002 for architecture security controls.
- **Human gate after work:** D-04 resource/region/spend approval and G5 remain pending.

### PH1-SEN-001 — WP-11 Mode A trust-boundary policy and data contract

- **Specialist role:** Sentinel, with Koban constraints and Ledger numeric-fidelity review.
- **Selected runtime:** Claude Code carrying Sentinel rules as an approved fallback.
- **Fallback reason:** Conserve native Sentinel/Hermes quota for high-value independent review and WP-15; Claude Code suits cross-document policy design.
- **Mode:** Documentation/design implementation in its own Git worktree.
- **Dependency:** Dispatch only after PH1-ARC-001 is integrated and accepted. This avoids rereading and reconciling a stale baseline. D-02/G4 Mode A is already approved.
- **Scope:** Finalize the Mode A data contract, deterministic explanation boundary, provider abstraction, deny-by-default broker design, audit/kill-switch requirements, and explicit Mode B-disabled conditions. No provider selection, provider call, production-data egress, or WP-12 code.
- **File ownership:** New LLM trust-boundary/policy artifacts and narrowly scoped cross-references after WP-02 integration. No WP-02-owned reconciliation edits in parallel.
- **Required evidence:** allowlist/deny rules, negative-test design, value-fidelity invariants, Mode B enablement prerequisites, changed-file list, and source traceability.
- **Review:** Nova; PH1-SEN-002 for independent security review; PH1-COD-001 carrying Ledger rules for numeric fidelity.
- **Human gate after work:** G4 is closed for Mode A only. Any Mode B enablement requires a new explicit approval.

### PH1-SEN-002 — Independent Wave 1 security review

- **Specialist role:** Sentinel reviewer.
- **Selected runtime:** Codex carrying Sentinel rules as an approved independent fallback.
- **Eligibility condition:** Codex must not implement any reviewed Wave 1 control. If Codex is used to implement part of PH1-CLD-002 or another reviewed artifact, it becomes ineligible for that scope and native Hermes Sentinel or another untouched approved runtime is required.
- **Mode:** Read-only review after the relevant implementation handoffs return.
- **Dependencies:** PH1-ARC-001, PH1-CLD-002, PH1-SHI-001, and PH1-SEN-001 outputs, reviewed incrementally or as one bounded evidence set.
- **Scope:** Security-document correctness, repository/CI controls, Mode A trust-boundary policy, and platform-design controls. This is not WP-15 and cannot grant release approval.
- **Required evidence:** control-by-control verdict, implementation-runtime eligibility statement, findings with severity, evidence references, and required remediation/re-review.
- **Review:** Nova validates independence and evidence.
- **Human gate:** None; findings may block package acceptance. Native Hermes Sentinel remains reserved/preferred for WP-15.

### PH1-COD-001 — Independent Ledger review of WP-11 value fidelity

- **Specialist role:** Ledger reviewer.
- **Selected runtime:** Codex carrying Ledger rules.
- **Independence:** PH1-SEN-001 is authored by Claude Code; Codex performs no WP-11 implementation.
- **Mode:** Read-only review after PH1-SEN-001.
- **Dependencies:** PH1-SEN-001 result and the approved Mode A decision.
- **Scope:** Verify deterministic explanations cannot alter authoritative engine values, the provider abstraction does not become a calculation source, and future token substitution requirements preserve numeric fidelity.
- **Required evidence:** invariant checklist, traceability assessment, findings, and explicit approve/block verdict for the Ledger review scope.
- **Review:** Nova validates evidence. This review does not close G2, which requires WP-03 financial baseline work later.

## Parallelization and integration plan

### Tranche 1 — parallel after dispatch approval

Run in separate Git worktrees:

1. PH1-ARC-001 — WP-02 documentation reconciliation.
2. PH1-CLD-002 — WP-01 repository foundation.
3. PH1-SHI-001 — WP-14 design/cost proposal only.

The worktrees isolate changes. File ownership is also constrained to reduce merge conflicts. PH1-ARC-001 owns reconciliation documents; PH1-CLD-002 owns workspace/toolchain files; PH1-SHI-001 owns new platform-design/proposal documents.

### Tranche 1 review and integration

- Validate each handoff independently.
- Run PH1-SEN-002 against completed security-relevant artifacts using Codex only if eligibility remains intact.
- Integrate PH1-ARC-001 before starting PH1-SEN-001.
- Integrate PH1-CLD-002 before PH1-SHI-001 finalizes application interface assumptions.
- Run repository-wide validation after integration.

### Tranche 2 — dependency-gated

1. PH1-SEN-001 starts after PH1-ARC-001 integration.
2. PH1-SEN-002 reviews its security policy output.
3. PH1-COD-001 performs independent Ledger value-fidelity review.

### Worktree and review constraints

- One worktree and branch per implementation assignment.
- No agent edits another assignment's worktree.
- The active orchestrator is the final integrator.
- Codex is reserved from Wave 1 implementation if it is to remain the Sentinel and Ledger review fallback.
- A runtime that implemented a reviewed control cannot approve it in a new session.
- Native Hermes Sentinel is not consumed by default in Wave 1 and remains preferred for WP-15.

## Dispatch gate

Wave 1 is technically ready for this staged dispatch plan. Dispatch still requires Gerso's explicit approval of these assignments. No assignment document, worktree, branch, agent, or runtime has been created or started by this proposal.
