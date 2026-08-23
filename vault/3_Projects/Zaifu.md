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
- **Phase 0 gate:** READY FOR OWNER APPROVAL

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

## Sentinel Escalations (pending Gerso decision)

1. Consumer MFA — require for MVP or accept residual risk?
2. LLM provider data handling — which provider, what retention/privacy terms?
3. Release gate evidence — who validates controls are deployed?
4. Household/multi-user — requires new auth + threat model review before Phase 2

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

## Related

- [[test-web-01]]
