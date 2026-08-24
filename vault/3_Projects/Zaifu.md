---
title: Zaifu
type: project
status: active
tags:
  - zaifu
  - personal-finance
  - decision-os
created: 2026-08-23
updated: 2026-08-23
---

# Zaifu

## What It Is

Zaifu is a **Decision Operating System for Personal Finance** — not a budgeting app or money tracker, but a system that helps people make confident financial decisions with transparent, explainable reasoning.

**Repository:** `/home/gerso/Development/zaifu` (branch: master)

## Architecture

Four deterministic engines coordinated by an AI orchestrator (Koban):

1. **Ledger** (Financial Engine) — Keeper of truth. Calculates current balances, obligations, available balance. Pure math, deterministic, no AI.
2. **Oracle** (Forecast Engine) — Predictor. Projects 30-day cash flow with conservative/expected/optimistic scenarios.
3. **Strategist** (Decision Engine) — Evaluator. Answers affordability questions, recommends timing, assesses risk.
4. **Steward** (Automation Engine) — Executor. Phase 2+; executes user-approved actions.

**Koban** orchestrates the engines conversationally. It never calculates finances directly — it coordinates, explains, and cites sources.

## MVP Scope

The refined MVP ("$500 purchase question"):
- User adds: checking balance + paycheck (amount, frequency, next date) + rent (amount, due day)
- User asks: "Can I afford a $500 purchase?"
- Koban answers with: verdict, reasoning, confidence level, alternatives, risk assessment

**Not in MVP:** credit cards, bank aggregation, multi-user households, investments, taxes, budgeting, categories.

## Phase Status

- **Phase 0 deliverables (Discovery & Charter):** COMPLETE
- **Phase 0 gate:** APPROVED by Gerso on 23-08-2026
- **Current phase:** Phase 1 Wave 1 PH1-SEN-001 integrated; PH1-SEN-002 and PH1-COD-001 awaiting final dispatch approval

## Key Decisions (21 ADRs)

See `docs/planning/DECISION_LOG.md` in the zaifu repo for full details. Highlights:
- ADR-002: Four deterministic engines + Koban orchestrator
- ADR-007: Money as integer minor units (cents), never float
- ADR-011: PostgreSQL + Prisma + pnpm monorepo
- ADR-017: Financial confidence as north star (not wealth optimization)
- ADR-021: MVP proof point is the "$500 purchase question"

## Phase 0 Specialist Work (August 23, 2026)

Three assignments dispatched in parallel:

| Assignment | Specialist | Transport | Result |
|---|---|---|---|
| PH0-ARC-001 | Archivist (real profile) | Herdr zexec | 5 product/planning docs created |
| PH0-SEN-001 | Sentinel (real profile) | Herdr zexec | 3 security docs created, 4 escalations |
| PH0-LDG-001 | Ledger (delegate_task fallback) | delegate_task | 3 architecture docs created |

**Disclosure:** Ledger assignment used delegate_task as a disclosed fallback (no Ledger Hermes profile in dispatcher allow-list). FINANCIAL_TEST_VECTORS.md was authored directly by Nova after two API timeouts (HTTP 524).

## Phase 1 Security and Scope Decisions (23-08-2026)

1. **Consumer MFA:** Required for the MVP as a baseline authentication control.
2. **LLM provider boundary:** Production financial data is denied by default.
   External providers are an explicit trust boundary; Phase 1 must define data
   allowlists, redaction/minimization, privacy/retention requirements, and
   access controls. Identifiable production financial data requires explicit
   future approval.
3. **Release evidence:** Sentinel owns independent pre-release security
   validation. Implementers produce evidence but cannot approve their own
   controls.
4. **Household/multi-user:** Deferred and prohibited in Phase 1 unless explicitly
   authorized; introduction requires a new authorization design and threat
   model review.

## Key Documents

**Product:**
- `docs/product/VISION.md` — the definitive narrative
- `docs/product/PHILOSOPHY.md` — 8 immutable principles
- `docs/product/FINANCIAL_CONFIDENCE.md` — confidence, not certainty
- `docs/product/TRUST_MODEL.md` — trust levels and confidence formula
- `docs/product/EXPLAINABILITY.md` — 6 components of every recommendation
- `docs/product/PRODUCT_CHARTER.md` — Phase 0 (Archivist)
- `docs/product/GLOSSARY.md` — all terms defined (Archivist)
- `docs/product/SUCCESS_METRICS.md` — M-01 through M-07 (Archivist)

**Architecture:**
- `docs/architecture/DOMAIN_MODEL.md` — entities, relationships, money rules (Ledger)
- `docs/architecture/FINANCIAL_ENGINE.md` — engine specs, algorithms (Ledger)
- `docs/architecture/FINANCIAL_TEST_VECTORS.md` — 22 test vectors (Ledger/Nova)

**Security:**
- `docs/security/SECURITY_ARCHITECTURE.md` — controls, encryption, auth (Sentinel)
- `docs/security/THREAT_MODEL.md` — attack surfaces, vectors, mitigations (Sentinel)
- `docs/security/DATA_CLASSIFICATION.md` — data levels and handling (Sentinel)

**Planning:**
- `docs/planning/USER_JOURNEYS.md` — J-01 through J-05 + edge cases (Archivist)
- `docs/planning/PRODUCT_REQUIREMENTS.md` — FR-01 through FR-12 + NFRs (Archivist)
- `docs/planning/PHASE_0_GATE_REVIEW.md` — Nova's gate review consolidation

## Technical Stack (planned)

- PostgreSQL + Prisma ORM
- pnpm workspaces monorepo
- NestJS API backend
- Next.js frontend (responsive web)
- Vercel (frontend) + Azure Container Apps (API)
- GitHub Actions + OIDC for CI/CD

## Phase 1 Planning (23-08-2026)

Gerso approved the Phase 0 gate and authorized Phase 1 planning. The four
binding decisions are recorded as ADR-022 through ADR-025.

`PH1-CLD-001` was dispatched read-only to Claude Code through Herdr. Claude
returned a 16-package implementation plan covering baseline reconciliation,
financial rules, foundation, schema, three engines, MFA, API, audit/export,
LLM trust-boundary policy and enforcement, web experience, platform, independent
Sentinel validation, and release readiness.

The active orchestrator accepted the plan with corrections:
- WP-03 must precede WP-04; they cannot run concurrently.
- WP-11 may start discovery with WP-02 but cannot finalize before WP-02 closes.
- WP-01 may design in parallel but cannot create package directories before the
  package-naming decision.
- The stated critical path is a dependency spine until packages are sized.
- Gates G1 through G6 require an explicit registry.
- Household/multi-user schema and behavior remain excluded unless separately
  justified and authorized.

Gerso approved the revised Phase 1 routing matrix at G1 on 2026-08-23. No
implementation was dispatched. Later gates and decisions remain binding,
including MFA method/recovery, LLM Mode A versus tokenized Mode B, WCAG target,
cloud spend/region/residency, document import scope, and retention.

### Specialist/runtime routing reassessment — 2026-08-23

The validated plan was reassessed under the rule that specialist roles and
execution runtimes are separate. Native Hermes remains preferred for Archivist,
Sentinel, and Shinobi, but runtime or quota unavailability does not remove those
roles. Claude Code and Codex may carry disclosed, approved specialist fallbacks
when their domain rules and evidence standards are preserved.

Sentinel approval must use a runtime that implemented none of the controls it
reviews; a new session of an implementing runtime is not independent. Native
Hermes Sentinel is therefore the preferred WP-15 reviewer. A Codex Sentinel
fallback is viable only if Codex is reserved from security-control
implementation.

Ledger has no native profile. Gerso approved the non-blocking Claude/Codex
separation: Claude performs Ledger-role baseline reconciliation and Codex
independently reviews it; Codex implements fixture-driven engines and Claude
independently performs Ledger-role review. Automated correctness and human
financial gates are unchanged.

Native Hermes Sentinel remains preferred for WP-15, with quota conserved for
high-value review and release-gate work. Earlier Sentinel review may use an
independent Claude/Codex fallback only when that runtime did not implement the
reviewed control. Gerso also approved disclosed Claude/Codex Shinobi fallbacks
and a disclosed Claude Archivist fallback when native runtimes are unavailable,
quota-constrained, or uneconomical.

Gerso subsequently approved D-05 (no import/upload; 70% trust ceiling), DO-06
(`financial-engine`, `forecast-engine`, `decision-engine` internally), D-02/G4
(Mode A only), and D-04 design-only treatment for WP-14. No cloud resource,
spend, deployment, provider-data egress, or Mode B activation is authorized.
These decisions are recorded append-only in Zaifu `docs/planning/DECISION_LOG.md`.

### Wave 1 Tranche 1 completion — 2026-08-23

Gerso authorized PH1-ARC-001, PH1-CLD-002, and design-only PH1-SHI-001. All ran
as real Claude Code sessions through Herdr in separate Zaifu worktrees. Claude
carried Archivist and Shinobi rules under the approved fallbacks; Codex and
native Hermes Sentinel were not used.

Results integrated to Zaifu `master` in order:

1. WP-02 baseline reconciliation (`ee41276`).
2. WP-01 pnpm/TypeScript workspace and CI foundation (`3315e65`, `2df8931`).
3. WP-14 design and post-WP-01 interface reconciliation (`f530a7a`, `ae8d873`).

Repository validation passed: frozen install, format/lint/typecheck, 9/9 tests,
49 Markdown files with 94 relative links and zero broken, and clean Git status.
Graphify refreshed to 1,481 nodes / 1,489 edges / 97 communities; generated
output is ignored.

Durable findings:

- PH1-ARC-001 made a minor scope breach by writing two benign validation scripts
  directly into the Ninjatronics handoff directory outside its worktree, then
  inaccurately attesting that Ninjatronics was untouched. The evidence was
  retained and the exception recorded.
- Two excluded documents retain legacy package-path names and need bounded
  follow-up before G2 baseline closure.
- WP-03/G2 must resolve the 70% trust ceiling versus answer threshold and band
  reachability; Tranche 1 did not invent a financial rule.
- Hosted secret scanning, push protection, branch protection, and real CI runs
  remain unavailable because Zaifu has no remote/host.
- D-04/G5 must jointly settle region, residency, backup redundancy, key
  management, and spend because PostgreSQL backup/key choices have creation-time
  constraints.
- WP-14 remains design only. No resource, credential, deployment, DNS, spend,
  production, or destructive action occurred.
- Codex remained independent through PH1-SEN-001: its Herdr state was unchanged,
  it implemented no reviewed control, and it remains eligible for PH1-SEN-002 and
  PH1-COD-001.

### PH1-SEN-001 execution (2026-08-23)

Gerso authorized PH1-SEN-001 only. Claude Code carried the Sentinel policy-author
role in isolated worktree `/home/gerso/Development/worktrees/zaifu/PH1-SEN-001`.
The bounded result created the Mode A trust-boundary policy and machine-readable
deny-by-default egress schema, plus narrow security-document cross-references and
project-local orchestration evidence. Exactly six owned paths changed.

The orchestrator independently found and corrected two record defects before
integration: UTC-derived `2026-08-24` dates instead of the required Los Angeles
`2026-08-23`, and a handoff sentence saying five files changed instead of six.
The amended result commit `266c6aa` was validated and integrated to Zaifu `master`
as `0cc5741`.

Validation: JSON parsed under Python/Node/jq; all 7 schema objects are closed with
`additionalProperties: false`; 32/32 fixtures passed with zero synthetic value
leaks; 21 relative links passed; scope and diff checks passed. The plan's
illustrative `SAFER_TO_WAIT` differs from the authoritative engine enum
`yes | no | maybe`; WP-12 must use the engine authority and recheck after G2.

No provider call, production-data access/egress, financial-rule change,
cloud/resource/spend action, deployment, Codex use, or Hermes use occurred. This
is policy authorship, not Sentinel approval or operating-control evidence. Mode B
remains disabled; G2 and the 70% ceiling/answer-threshold issue remain open.

PH1-SEN-002 and PH1-COD-001 remain undispatched. They may be proposed as separate
read-only Codex reviews only after Gerso's final dispatch approval. Native Hermes
is not an eligible execution runtime under the current runtime policy.

G2, D-01/G3, D-03, D-06, D-07/G6, and G5 resource/spend approval remain pending.
Artifacts: `shared/handoffs/PH1-CLD-001/tranche-1-results.md`,
`shared/handoffs/PH1-SEN-001/`, and each Tranche 1 assignment directory under
`shared/handoffs/`.

Evidence:
- `shared/handoffs/PH1-CLD-001/assignment.md`
- `shared/handoffs/PH1-CLD-001/result.md`
- `shared/handoffs/PH1-CLD-001/transport.json`
- `shared/handoffs/PH1-CLD-001/validation.md`
- `shared/handoffs/PH1-CLD-001/routing-reassessment.md`
- `shared/handoffs/PH1-CLD-001/first-wave-proposal.md`
- Zaifu `docs/orchestration/handoffs/PH1-CLD-001.md`

## Harness Interoperability (23-08-2026)

Pi and Nova/Hermes are now supported as interchangeable active orchestrators.
Existing references to Nova mean the orchestrator role unless runtime identity
is explicitly required.

The shared resume workflow now discovers the central assignment ledger,
project-local orchestration records, project-aware shared handoffs (including
retry suffixes), phase/gate records, the matching vault project note, the latest
relevant daily note, and Graphify availability/freshness guidance. It excludes
unrelated projects' shared handoffs.

Validation completed:
- Resume workflow tests: 12 passed, 0 failed
- Specialist dispatcher regression tests: 18 passed, 0 failed
- Pi/Hermes resume prompts are equivalent except for the harness identity
- Graphify refreshed and the new resume/harness symbols verified present

Historical Phase 0 orchestration reconciliation remains deferred as a separate
cleanup task.

## Related

- [[test-web-01]]
