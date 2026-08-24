# Assignment

## Assignment ID

`PH1-CLD-002`

## Owner

Forge role executed by Claude Code as approved.

## Requested by

Pi acting as active orchestrator (Nova role)

## Priority

High

## Objective

Implement WP-01: a minimal, strict pnpm/TypeScript monorepo foundation and CI validation baseline for Zaifu, with no product-feature or engine implementation.

## Context

Gerso approved Wave 1 Tranche 1 dispatch on 2026-08-23. DO-06 fixes internal package names as `financial-engine`, `forecast-engine`, and `decision-engine`; Ledger, Oracle, and Strategist remain domain/product names. Zaifu currently contains documentation only.

## Scope

Repository: `/home/gerso/Development/zaifu`, isolated assignment worktree/branch.

Exclusive implementation ownership:

- Root workspace/toolchain files: `package.json`, `pnpm-workspace.yaml`, lockfile, TypeScript/ESLint/format/test configuration, and narrowly necessary root ignore/config files.
- `.github/workflows/ci.yml` only.
- Empty/minimal compileable scaffolding under `apps/web/**`, `apps/api/**`, `packages/financial-engine/**`, `packages/forecast-engine/**`, and `packages/decision-engine/**`.
- Exact project-local orchestration files `docs/orchestration/assignments/PH1-CLD-002.md` and `docs/orchestration/handoffs/PH1-CLD-002.md`.

## Out of scope

- Any financial, forecast, decision, Koban, authentication, API, UI, persistence, schema, infrastructure, deployment, or cloud behavior.
- Any business/domain model, production dependency not required for workspace validation, or package implementation beyond minimal placeholders/tests needed to prove wiring.
- Existing planning/product/security/architecture documentation.
- `docs/platform/**`, deploy workflows, live IaC, cloud configuration, repository-host settings, credentials, resources, spend, DNS, or production changes.
- Claiming secret scanning or branch protection is enabled when it cannot be configured locally.

## Inputs

- `shared/handoffs/PH1-CLD-001/result.md` WP-01.
- `shared/handoffs/PH1-CLD-001/validation.md`, `routing-reassessment.md`, and `first-wave-proposal.md`.
- Zaifu ADR-002, ADR-019, ADR-024, and approved DO-06 addendum.
- Existing repository conventions and available local tool versions; inspect rather than guess.

## Graphify context

- Command run: `graphify query "What are PH1-ARC-001 PH1-CLD-002 PH1-SHI-001, their work packages, dependencies, file ownership boundaries, handoff requirements, and Wave 1 integration order?"`
- The graph identified the Phase 1 plan and ownership table; verify against source. Zaifu has no local Graphify graph, so use direct inspection there.

## Constraints

- Work only in the assigned worktree and branch.
- Stay within exclusive ownership. Stop before editing any other path.
- Inspect installed Node/pnpm versions and repository state; do not guess versions.
- Do not install system/global packages. Project dependency installation is allowed only as needed for WP-01 and must be represented in the lockfile.
- Use strict TypeScript settings and preserve an acyclic workspace graph.
- Commit the bounded change. Do not merge, push, or alter another branch/worktree.
- Keep Codex unused so it remains review-eligible.

## Required deliverables

- pnpm workspace and strict TypeScript validation foundation.
- Minimal scaffolding for two apps and the three approved engine packages.
- CI workflow for install, formatting/linting, typecheck, and tests with least-privilege permissions and no secret-bearing behavior.
- Project-local assignment and handoff in the exact paths above.
- Concise final response with commit SHA and handoff path.

## Validation required

- Clean-checkout-compatible locked install using the inspected package manager.
- Formatting/lint, typecheck, and test commands all pass.
- Workspace dependency graph is acyclic and package names are exact.
- `git diff --check`, changed-file boundary check, and clean status after commit.
- CI syntax/configuration reviewed locally; unavailable hosted settings are reported, not fabricated.

## Evidence required

Exact tool versions, commands/results, changed-file list, dependency graph/list, commit SHA, CI permissions/scanning evidence, before/after status, and explicit no-feature/no-cloud/no-resource/no-spend statement.

## Dependencies

G1 and DO-06 are satisfied. No dependency on PH1-ARC-001 implementation.

## Escalation conditions

Need for a package-name/layout change; need to implement product behavior; dependency/tool incompatibility requiring material architecture choice; need to modify owned documentation or cloud/repository settings.

## Completion criteria

Workspace installs reproducibly and all local validation passes; only owned files changed; no product behavior exists; commit is ready for orchestrator validation.

## Recommended next owner

Active orchestrator for independent validation and integration, then PH1-SEN-002 for repository/CI security review when authorized.
