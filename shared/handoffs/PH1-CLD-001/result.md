# Handoff: PH1-CLD-001 — Phase 1 Implementation Plan

**Specialist role:** Claude Code (execution runtime; no specialist domain assumed)
**Assignment:** Convert approved Phase 0 architecture into a sequenced Phase 1 implementation plan
**Completed:** 2026-08-23
**Mode:** Strictly read-only analysis. No file in Zaifu or Ninjatronics was created, modified, or deleted.
**Recommended next owner:** Active orchestrator (validation and synthesis) → Gerso (plan approval)

---

## 1. Executive summary

Zaifu's Phase 0 documentation set is unusually complete for a pre-implementation
product: requirements, journeys, domain model, engine specification, test
vectors, threat model, data classification, and a security architecture all
exist and cross-reference each other. The Phase 0 gate is approved and four
binding owner decisions (ADR-022 through ADR-025) are recorded.

The repository contains **no implementation of any kind**. Verified by direct
inspection: no `package.json`, no `pnpm-workspace.yaml`, no TypeScript source,
no Prisma schema, and `.github/workflows/` exists but is empty. Phase 1 is
therefore a from-zero build of a single-user, MFA-protected, responsive web
application with three deterministic calculation engines, an orchestration
layer, and a full security-evidence trail.

The plan below defines **16 bounded work packages** (`PH1-WP-01` … `PH1-WP-16`),
their dependency graph, acceptance and evidence requirements, owner/runtime
recommendations, and approval gates.

Three findings dominate the sequencing and must be read before the package list:

1. **The financial baseline is not yet safe to implement against.** The approved
   test-vector file — which `NFR-02` and `M-08` make a 100%-pass release gate —
   contains inline output values that contradict their own derivations
   (TV-03 states `confidence: 74` where its derivation and the summary table
   both say 77; TV-16 states 50 where the derivation says 55; TV-17 states 24
   where the derivation says 22), and it contains unresolved authoring notes in
   the body ("Actually let me use the formula precisely..."). Three documents
   also give three different definitions of `assumption_trust` and two different
   rounding rules. This is not a documentation nit: it changes user-visible
   verdicts at the 70% confidence threshold. `PH1-WP-03` exists to close this
   before any engine is written.

2. **The security baseline document contradicts the owner's binding MFA
   decision.** `docs/security/SECURITY_ARCHITECTURE.md:93` still states that
   "MFA is not asserted as an MVP implementation requirement," and
   `THREAT_MODEL.md:72`/`:107` still treat consumer MFA posture as an open
   residual-risk decision. ADR-022 overrode this on 23-08-2026. Sentinel's own
   review baseline must be corrected before Sentinel can validate against it.

3. **ADR-023 and FR-09 are in tension and the resolution is an owner
   decision, not a planning assumption.** FR-09 requires Koban to produce
   conversational, six-component explanations of a user's specific financial
   position. ADR-023 forbids production financial data from crossing an external
   LLM boundary by default. The plan resolves this with a **tokenized-egress
   design** (Section 8) in which the model never receives real monetary values
   or identifiers, and authoritative numbers are re-substituted server-side.
   This satisfies both constraints and additionally guarantees `M-11` (100%
   Koban value fidelity) structurally rather than probabilistically. It is
   recommended, not assumed: `D-02` in the decision register puts the choice
   to Gerso.

**The plan is implementation-ready and contains no implementation.** No code,
schema, configuration, or test was written. No follow-up agent was dispatched.

---

## 2. Planning assumptions

These are stated explicitly because they were not independently verifiable from
the sources, or because a reasonable alternative exists.

| # | Assumption | Basis | If wrong |
|---|---|---|---|
| A-01 | Phase 1 delivers a deployable single-user MVP, not a further design phase. | `PHASE_0_GATE_REVIEW.md` addendum: "Next phase: Phase 1 planning"; `README.md` "Phase 1 (Requirements)"; `MVP_PROOF_POINT.md` "Implementation Scope (Phase 1)". | If Phase 1 is requirements-only, WP-04 through WP-16 become Phase 2 and only WP-01/02/03/11 apply. Escalation E-07. |
| A-02 | The refined MVP boundary (`MVP_REFINED.md` + `PRODUCT_CHARTER.md` "In scope now") governs, superseding `MVP_PROOF_POINT.md` and ADR-021 where they include credit cards. | `PHASE_0_GATE_REVIEW.md` conflict resolution #4; assignment Constraints. | No effect on plan; already applied. |
| A-03 | `PRODUCT_REQUIREMENTS.md` FR-01…FR-12 and NFR-01…NFR-05 are the acceptance surface for product behavior. | It is the newest product-behavior document and the gate review cites it as the MVP boundary artifact. | Acceptance criteria in WP-13/WP-16 shift. |
| A-04 | The stack is fixed by ADR-011/ADR-012: pnpm workspaces, PostgreSQL, Prisma, Next.js on Vercel, NestJS-style API on Azure Container Apps, GitHub Actions with OIDC. | ADR-011, ADR-012, `AGENT_ROSTER.md` (Forge owns "NestJS API architecture, Prisma schema"). | WP-01/WP-04/WP-14 change; downstream packages unaffected. |
| A-05 | Steward (`automation-engine`) is **not** built in Phase 1. | ADR-002 lists it, but `PRODUCT_CHARTER.md` non-goals and `NFR-05` forbid any money movement or automation in the MVP. | Adds a package; would require a new threat-model pass. |
| A-06 | Document/statement upload is **excluded** from Phase 1 (see C-02). Trust Level 3 ("Verified Statement", 85%) is therefore unreachable in Phase 1; the maximum reachable account trust is Level 2 (User Confirmed, 70%). | `PRODUCT_REQUIREMENTS.md` MVP exclusions ("document import"); `MVP_PROOF_POINT.md` "❌ Document import"; `USER_JOURNEYS.md` contains no import journey. | Material. Adds a whole import/OCR/malware-scanning package and re-opens TM-06/TM-07. Blocked on decision `D-05`. |
| A-07 | "Ninjatronics standards" means the four files named in the assignment; `specialist-transport.md` was also read because `agent-routing.md` normatively references it for dispatch. | Assignment Inputs; `agent-routing.md` dispatch section. | None. |
| A-08 | Estimates are deliberately omitted. No historical velocity data for this team exists in either repository, and inventing durations would create false precision in a plan Gerso is asked to approve. | — | Orchestrator may add sizing before dispatch. |

---

## 3. Authoritative baseline

### 3.1 Governing hierarchy

Derived from `PRODUCT_CHARTER.md` ("If this charter conflicts with VISION.md or
PHILOSOPHY.md, those governing documents take precedence"), the gate-review
conflict resolutions, and ADR recency.

```
Tier 0  Owner decisions            ADR-022, ADR-023, ADR-024, ADR-025
                                   PHASE_0_GATE_REVIEW.md "Gate Approval Addendum"
Tier 1  Product invariants         VISION.md, PHILOSOPHY.md, FINANCIAL_CONFIDENCE.md (ADR-017)
Tier 2  Scope boundary             MVP_REFINED.md, PRODUCT_CHARTER.md "MVP boundary"
Tier 3  Behavioral acceptance      PRODUCT_REQUIREMENTS.md (FR/NFR), USER_JOURNEYS.md
Tier 4  Domain + calculation       DOMAIN_MODEL.md, FINANCIAL_ENGINE.md, FINANCIAL_TEST_VECTORS.md
Tier 5  Security controls          SECURITY_ARCHITECTURE.md, THREAT_MODEL.md, DATA_CLASSIFICATION.md
Tier 6  Narrative / illustrative   MVP_PROOF_POINT.md, USER_STORY_BEST_BUY.md, README.md
```

Tier 6 documents are illustrative and must not be used to justify scope.

### 3.2 Source contradictions requiring resolution

Each is verified against the file and line. **Blocking** means an implementer
cannot proceed without guessing.

| ID | Contradiction | Evidence | Impact | Resolve in | Blocking |
|---|---|---|---|---|---|
| **C-01** | Security architecture denies the MFA baseline the owner approved. | `SECURITY_ARCHITECTURE.md:93` "MFA is not asserted as an MVP implementation requirement"; `:145` residual-risk row "decide MVP MFA posture"; `THREAT_MODEL.md:72` "MFA posture is an explicit MVP residual-risk decision"; `:107` item 1. Overridden by **ADR-022**. | Sentinel would validate WP-08 against a baseline that says MFA is optional. Directly defeats ADR-024. | WP-02 | **Yes** |
| **C-02** | Is statement/document upload in the MVP? | **In:** ADR-010 ("MVP supports CSV import and document upload with OCR"); `MVP_REFINED.md` Step 2 requires uploading a screenshot/statement to reach 85% trust; `TRUST_MODEL.md` Level 3 and the import workflow; `PHASE_0_GATE.md` "Import workflow is specified". **Out:** `PRODUCT_REQUIREMENTS.md` MVP exclusions lists "document import"; `PRODUCT_CHARTER.md` "In scope now" omits it; `MVP_PROOF_POINT.md` "❌ Document import". | Changes Phase 1 scope by an entire subsystem (upload, isolation, malware scan, OCR, provenance, confirmation) and re-opens TM-06/TM-07. Also caps reachable trust at 70%, which changes every confidence output. | Decision **D-05**, then WP-02 | **Yes** |
| **C-03** | Gate review cites a journey that does not exist. | `PHASE_0_GATE_REVIEW.md` line ~63: "Import workflow specified — docs/planning/USER_JOURNEYS.md J-04" and lists "J-04: Import data". Actual `USER_JOURNEYS.md` J-04 is **"Review the 30-day forecast"**; the file contains no import journey. | The gate criterion "Import workflow is specified" was checked against a non-existent artifact. Compounds C-02. | WP-02 (+ orchestrator note to gate record) | **Yes** |
| **C-04** | `assumption_trust` has three incompatible definitions. | `FINANCIAL_ENGINE.md` §3.4: `(income_arrival_trust + no_unexpected_trust[60]) / 2` → worked example 72.5. `TRUST_MODEL.md`: `(emergency_fund[40] + next_paycheck_date[60]) / 2` = 50. `FINANCIAL_TEST_VECTORS.md` Input Format: `(next_paycheck_date[60] + safety_threshold[40]) / 2` = 50, but TV-17 uses 40 with a different rationale. | The engine spec's own worked example yields 84% where the vectors yield 81% for identical inputs. Confidence gates the 70% answer/ask threshold, so this changes verdicts. | WP-03 | **Yes** |
| **C-05** | Confidence rounding: nearest vs floor. | `FINANCIAL_ENGINE.md` §3.4 step 6: "Round to nearest integer (standard rounding)". `FINANCIAL_TEST_VECTORS.md`: `confidence = floor(...)` and every derivation uses `floor`. | At 69.5 one rule answers and the other asks. | WP-03 | **Yes** |
| **C-06** | Test-vector output blocks contradict their own derivations. | TV-03 output `confidence: 74`, derivation and summary table `77`. TV-16 output `confidence: 50`, derivation/table `55` (with an inline "**Corrected:**" block). TV-17 output `confidence: 24`, derivation/table `22`. TV-03 body contains the authoring note "Actually let me use the formula precisely:". | These are the `NFR-02`/`M-08` release-gate fixtures. As written they cannot produce a deterministic 100% pass. | WP-03 | **Yes** |
| **C-07** | Verdict vocabulary differs across three authoritative documents. | `FINANCIAL_ENGINE.md` §3.1: `"yes" \| "no" \| "maybe"`. `FINANCIAL_TEST_VECTORS.md`: `"afford" \| "do_not_afford" \| "ask_for_more_info"`. `PRODUCT_REQUIREMENTS.md` FR-08: "affordable now, safer to wait, or not supported by the current outlook" (+ FR-06 insufficient-data path). | API contract, engine return type, fixtures, and UI copy cannot all be right. Note the semantics differ too: FR-08's "safer to wait" is a timing recommendation, while the engine's "maybe" is a scenario-divergence state. | WP-03 (canonical enum) | **Yes** |
| **C-08** | Package naming: brand vs code names. | **ADR-019 (Phase 0, Final)**: code is `packages/financial-engine`, `packages/forecast-engine`, `packages/decision-engine`, `packages/automation-engine`, `apps/api/src/koban` — "Code (internal, forever)". **ADR-002 Consequences** and `FINANCIAL_ENGINE.md` Engine Overview table say `packages/ledger`, `packages/oracle`, `packages/strategist`, `packages/steward`. `AGENT_ROSTER.md` says "`packages/oracle` (future naming: Oracle)". | Determines the workspace layout created in WP-01 and every import path thereafter. Renaming later is a cross-repo refactor. ADR-019 is later and explicitly final; recommend ADR-019 wins. | WP-01 / WP-02 | **Yes** |
| **C-09** | May sub-70% trust data be used in calculations? | `TRUST_MODEL.md` Level 1 (20%): "**Not for calculations.** Only for asking clarifying questions." `DOMAIN_MODEL.md` "How Trust Affects Calculations": "20%–69%: Data **is** used for calculations but recommendations are marked as low-confidence." `THREAT_MODEL.md` TM-07 requires a "negative test showing unconfirmed data excluded from calculation". `FINANCIAL_TEST_VECTORS.md` TV-17 computes a `lowest_balance_cents` from all-unverified inputs while returning `ask_for_more_info`. | Determines whether Ledger/Oracle refuse to compute or compute-and-withhold. Changes engine control flow, API responses, and a Sentinel negative test. TV-17 implies compute-then-withhold; TRUST_MODEL implies refuse. | WP-03 | **Yes** |
| **C-10** | Confidence presentation: label vs percentage. | Gate review resolution #1 (labels externally, percentages internally). Still-percentage sources: `TRUST_MODEL.md` user-facing examples ("Confidence: 87%"), `MVP_REFINED.md` ("Confidence: 79%"), `MVP_PROOF_POINT.md` ("Confidence: 96%"). `FINANCIAL_CONFIDENCE.md` and FR-09 require HIGH/MEDIUM/LOW. | UI copy. Non-blocking (resolution recorded) but the stale examples will mislead WP-13. Also: the label→band mapping (which percentages map to HIGH/MEDIUM/LOW) is **not defined anywhere**; `TRUST_MODEL.md` "User-Facing Trust Display" implies 85+/70–84/<70. | WP-02 (+ define bands in WP-03) | No, but must be specified |
| **C-11** | `EXPLAINABILITY.md` titled "five components", enumerates six. | File heading vs. sections 1–6; FR-09 requires six. Gate resolution #2: six is correct. | Cosmetic; FR-09 already binding. | WP-02 | No |
| **C-12** | ADR-003 has no heading. | `DECISION_LOG.md` — the multi-provider abstraction ADR sits between ADR-016 and ADR-004 with `**Status:**` but no `## ADR-003:` line. `grep -n '^## ADR' ` returns no ADR-003. | Traceability defect; ADR-003 is cited by WP-11/WP-12 work. | WP-02 | No |
| **C-13** | Same-date event ordering is an optimistic assumption inside the *expected* scenario. | `FINANCIAL_ENGINE.md` §2.1: "When income and obligations fall on the same day, income is applied first... This is the optimistic interpretation." FR-07 requires "material ordering assumptions for events on the same date are visible". TV-13 exercises it. | Not a contradiction, but an embedded product judgement that must be surfaced in the UI and confirmed. | WP-03 (record as explicit rule), WP-13 (surface it) | No |
| **C-14** | ADR-021 and `MVP_PROOF_POINT.md` still include a credit card in the proof-point flow. | ADR-021 step 4 "Adds one credit card"; `MVP_PROOF_POINT.md` "✅ Account setup (checking, paycheck, bill, credit card)". Superseded by `MVP_REFINED.md` per gate resolution #4. | Already resolved; stale text will mislead implementers. | WP-02 | No |
| **C-15** | `README.md` reports Phase 0 "In progress". | `README.md` "Current Phase: Phase 0: Discovery and Charter — Status: In progress". Gate is APPROVED. Also references `ROADMAP.md`, `docs/architecture/adr/`, `KOBAN_ARCHITECTURE.md`, and `docs/product/USER_JOURNEYS.md` — none exist (journeys live in `docs/planning/`). | Orientation doc is stale; new implementers start here. | WP-02 | No |
| **C-16** | TV-22 tests `bank_synced` (100%) trust. | `FINANCIAL_TEST_VECTORS.md` TV-22; but ADR-004/ADR-010 place bank sync in Phase 2+. | A Phase 1 release-gate vector exercises an unreachable state. Keep as forward-compat, exclude from the Phase 1 100%-pass denominator, or the gate is unpassable. | WP-03 | No |
| **C-17** | `.gitignore` ignores `*.pdf` globally. | `.gitignore` under "Personal financial data". | Correct intent, but will silently block any future PDF evidence artifact Sentinel or Archivist tries to commit. Note for WP-14/WP-15 evidence handling. | WP-02 | No |

### 3.3 Traceability of the four binding decisions

| Decision | Represented in |
|---|---|
| **ADR-022** MFA is an MVP baseline | WP-02 (C-01 correction), **WP-08** (implementation), WP-13 (enrolment/challenge/recovery UI), WP-15 (independent validation), gate **G3**, decision **D-01** |
| **ADR-023** External LLM is an explicit trust boundary | **WP-11** (policy + data contract), **WP-12** (deny-by-default enforcement), WP-10 (egress audit events), WP-15 (provider-handling validation), gate **G4**, decision **D-02**, Section 8 |
| **ADR-024** Sentinel owns independent release validation | **WP-15** (Sentinel-owned, cannot be executed by any implementing package); every implementing package carries an explicit "Evidence returned to Sentinel" clause; gate **G6** |
| **ADR-025** Household/multi-user deferred | Every package carries "no household/multi-user" in out-of-scope; WP-04 exposes `household_id` as a **nullable, unused** column with a schema-level single-user constraint; WP-09 forbids any client-supplied tenant identity; WP-15 tests cross-subject denial |

---

## 4. Work packages

Common to every package unless stated otherwise:

- **Out of scope (all packages):** household or multi-user functionality, shared
  access, invitations, delegated access, roles beyond the single owning subject
  (ADR-025); credit cards, interest, debt prioritization, subscriptions, goals,
  budget categories, bank aggregation, investments, taxes, autonomous money
  movement (`PRODUCT_CHARTER.md` non-goals); sending production financial data
  to an external LLM provider (ADR-023); self-approval of security controls
  (ADR-024).
- **Common evidence:** files changed, commands run, test output with counts,
  and the assumptions list, per `collaboration-workflow.md` §"Handoff format".
- **Common review:** Nova acceptance. Security-relevant packages add Sentinel.

---

### PH1-WP-01 — Monorepo foundation and toolchain

**Objective.** Create the empty-but-correct repository skeleton so every later
package has a place to land and a CI gate to pass.

**Scope.** pnpm workspace definition; root and per-package TypeScript config
with strict mode; lint and format configuration; test runner; the workspace
layout for `apps/api`, `apps/web`, and the three engine packages plus a shared
domain-types package; a CI workflow that installs, lints, type-checks, and runs
tests on pull request; branch protection requirements documented; secret
scanning enabled.

**Explicitly out of scope.** Any deployment workflow or cloud resource (WP-14);
any engine, schema, or feature logic; `packages/automation-engine` (Steward,
per A-05).

**Likely files.** `package.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`,
`.eslintrc`, `.prettierrc`, `vitest.config.ts`, `.github/workflows/ci.yml`,
placeholder `package.json` per workspace, `CONTRIBUTING.md`.

**Dependencies.** None (repository root is empty of code). Requires the C-08
naming resolution before the workspace directories are named — see G2.

**Acceptance criteria.**
1. `pnpm install` succeeds from a clean checkout.
2. `pnpm -r lint`, `pnpm -r typecheck`, `pnpm -r test` all succeed and are wired
   into CI on pull request.
3. Workspace directory names match the ADR-019 code names (`financial-engine`,
   `forecast-engine`, `decision-engine`) or the documented alternative approved
   at G2 — and match ADR-002/`FINANCIAL_ENGINE.md` after WP-02 reconciles them.
4. TypeScript strict mode is on; `any` is lint-blocked in engine packages.
5. Secret scanning is enabled on the repository (`security-review.md` §1).
6. No workspace depends on another in a cycle; `pnpm -r list` is acyclic.

**Validation and evidence.** CI run URL with green result; `pnpm install`
output; lint/typecheck/test output; screenshot or API export of branch
protection and secret-scanning settings.

**Owner / runtime.** Forge (domain) / **Claude Code**.
**Reviewer.** Nova. Sentinel for the secret-scanning and branch-protection items.
**Human gate.** G2 (naming resolution) before directories are created.

**Traces to.** ADR-001, ADR-011, ADR-019; `security-review.md` §1, §7.

---

### PH1-WP-02 — Authoritative baseline reconciliation

**Objective.** Bring the Phase 0 document set into agreement with the four owner
decisions and with itself, so that every later package implements one baseline
rather than choosing between three.

**Scope.** Resolve C-01, C-02 (per decision D-05), C-03, C-08, C-10 (label
bands), C-11, C-12, C-14, C-15, C-17. Update `SECURITY_ARCHITECTURE.md` and
`THREAT_MODEL.md` to state MFA as a required baseline control with the
recovery-flow and monitoring requirements that follow from it. Correct the gate
record's J-04 citation. Add the missing ADR-003 heading. Record every change as
a dated correction with rationale; do not silently rewrite history.

**Explicitly out of scope.** Any change to `FINANCIAL_TEST_VECTORS.md`,
`FINANCIAL_ENGINE.md` §3.4, or the confidence/verdict/trust-usage rules — those
are WP-03's exclusive ownership (C-04, C-05, C-06, C-07, C-09, C-13, C-16). No
new requirements. No scope expansion.

**Likely files.** `docs/security/SECURITY_ARCHITECTURE.md`,
`docs/security/THREAT_MODEL.md`, `docs/planning/PHASE_0_GATE_REVIEW.md`,
`docs/planning/DECISION_LOG.md` (ADR-003 heading; possibly a new ADR recording
the C-08 resolution), `docs/product/EXPLAINABILITY.md`, `README.md`,
`docs/planning/MVP_PROOF_POINT.md` (supersession banner), `.gitignore`.

**Dependencies.** Decision **D-05** (import in/out) must land before the scope
sections are finalized. Otherwise none — runs in parallel with WP-01.

**Acceptance criteria.**
1. No document states or implies that MFA is optional for the MVP; every MFA
   reference is consistent with ADR-022.
2. The MVP scope statement regarding document/statement upload is identical in
   `PRODUCT_CHARTER.md`, `PRODUCT_REQUIREMENTS.md`, `MVP_REFINED.md`, ADR-010,
   and `TRUST_MODEL.md`, and states the maximum trust level reachable in Phase 1.
3. Exactly one package-naming convention appears across ADR-002, ADR-019,
   `FINANCIAL_ENGINE.md`, and `AGENT_ROSTER.md`.
4. The HIGH/MEDIUM/LOW confidence bands are defined once, with numeric
   boundaries, in a single named location, and every user-facing example in
   `TRUST_MODEL.md`, `MVP_REFINED.md`, and `MVP_PROOF_POINT.md` either uses a
   label or is marked as an internal-value illustration.
5. Every ADR in `DECISION_LOG.md` has a heading; `grep -c '^## ADR' ` equals the
   ADR count.
6. `README.md` reflects the approved gate and contains no link to a
   non-existent file.
7. A dated reconciliation record lists each change, the sources it resolved, and
   the resolution rationale.

**Validation and evidence.** A contradiction-closure table mapping C-01…C-17 to
the commit that closed each (or to the package deferring it); `git diff --stat`;
a link-check run over `docs/` showing zero broken relative links.

**Owner / runtime.** Archivist (domain) / **Claude Code** — cross-document
long-context reconciliation is exactly the shape `agent-routing.md` assigns to
Claude Code.
**Reviewer.** Sentinel **must** approve the `SECURITY_ARCHITECTURE.md` and
`THREAT_MODEL.md` edits (Sentinel owns those documents per `AGENT_ROSTER.md`);
Nova approves the rest.
**Human gate.** G2 — Gerso confirms the reconciled baseline, because C-02 and
C-08 change scope and structure.

**Traces to.** ADR-022, ADR-023, ADR-025; gate-review conflict resolutions #1–#5;
`orchestration.md` §Archivist ("must not invent evidence").

---

### PH1-WP-03 — Canonical calculation rules and machine-readable fixtures

**Objective.** Produce one unambiguous, executable definition of every MVP
financial rule, and convert the 22 test vectors into machine-readable fixtures
that can serve as the `NFR-02` / `M-08` release gate.

**Scope.** Resolve and record: `assumption_trust` definition (C-04); rounding
rule (C-05); the canonical verdict enum and its mapping to FR-08's user-facing
states (C-07); whether sub-70% trust data is computed-and-withheld or refused
(C-09); the same-date ordering rule and how it is disclosed (C-13); the
confidence→label bands; the Phase 1 applicability of TV-22 (C-16). Correct every
vector whose inline output disagrees with its derivation (C-06) and remove the
authoring notes. Emit the vectors as versioned JSON fixtures consumed directly
by WP-05/06/07 tests. Add vectors for any FR-07/FR-08 behavior the current 22 do
not cover — in particular the FR-06 missing-critical-data path and the FR-05
conflicting-sources path, neither of which has a vector today.

**Explicitly out of scope.** Implementing any engine. Changing MVP scope. Adding
Phase 1.1 rules (interest, utilization, minimum payments) beyond keeping them
marked as defined-not-implemented.

**Likely files.** `docs/architecture/FINANCIAL_TEST_VECTORS.md`,
`docs/architecture/FINANCIAL_ENGINE.md` (§3.4 only),
`packages/financial-fixtures/vectors/*.json`, `packages/financial-fixtures/schema.json`.

**Dependencies.** WP-01 (a place to put the fixture package); WP-02 (naming and
label bands). Blocks WP-05, WP-06, WP-07.

**Acceptance criteria.**
1. Every fixture's stated output equals the output its own derivation produces —
   verified by a script, not by reading.
2. `assumption_trust`, the rounding rule, and the verdict enum each have exactly
   one definition, cited from exactly one location.
3. Every one of the 22 vectors is expressible as fixture JSON validating against
   the published schema; any vector excluded from the Phase 1 gate (e.g. TV-22)
   is listed with its exclusion rationale, and the `M-08` denominator is stated.
4. The C-09 rule is stated as an implementable predicate (which inputs at which
   trust levels cause refusal versus computation-with-withheld-verdict), and a
   fixture exercises each side of it.
5. Fixtures cover: FR-06 missing-critical-data, FR-05 conflicting-sources,
   FR-10 correction-triggers-recalculation, and the same-date ordering rule.
6. The fixture set carries a version identifier and a recorded financial-domain
   approval, per `SUCCESS_METRICS.md` "Accuracy evidence requirements"
   ("reference-case set version and Ledger approval").
7. No fixture contains a monetary value expressed as anything but integer cents.

**Validation and evidence.** Output of the derivation-checking script over all
fixtures; schema validation output; the versioned fixture set; the recorded
domain-owner approval; a diff table of every value corrected (old → new →
source of truth).

**Owner / runtime.** **Ledger** (financial domain owner — `AGENT_ROSTER.md`
gives Ledger co-architect authority and states "no financial changes bypass
Ledger review") / **Claude Code** — resolving three conflicting definitions
across four documents is judgement work, not mechanical transformation.
**Reviewer.** Nova, independently (see Escalation E-04 — no real Ledger runtime
profile exists).
**Human gate.** G2 — Gerso ratifies the corrected financial baseline, since it
changes user-visible verdicts and the release gate.

**Traces to.** ADR-007, ADR-014, ADR-017, ADR-021; NFR-02; M-08, M-09, M-10;
`FINANCIAL_TEST_VECTORS.md` coverage matrix.

---

### PH1-WP-04 — Domain types, persistence schema, and audit substrate

**Objective.** Implement the `DOMAIN_MODEL.md` entities as typed, integer-cent,
provenance-bearing, single-user-enforced persistence with an append-oriented
audit substrate.

**Scope.** A pure `domain-types` package (entity types, trust-level enum, money
type and helpers, recurrence types) with no database dependency. Prisma schema
for User, Account, Income, Obligation, Transaction, plus the audit-event table
and correction/provenance records. Migrations. Encryption-at-rest configuration
for the database and its backups. Seed data for local development that contains
no real financial data. `CreditCard` defined but not migrated (or migrated as an
unused table — decide and record).

**Explicitly out of scope.** Any HTTP surface (WP-09). Any engine logic
(WP-05/06/07). Multi-account, multi-currency, subscriptions, goals. Any
household table or role table beyond the nullable `household_id` column.

**Likely files.** `packages/domain-types/src/**`, `apps/api/prisma/schema.prisma`,
`apps/api/prisma/migrations/**`, `apps/api/prisma/seed.ts`.

**Dependencies.** WP-01, WP-02 (naming), WP-03 (money and rounding rules).
Blocks WP-05/06/07 (types), WP-08 (user), WP-09, WP-10.

**Acceptance criteria.**
1. Every monetary column is an integer type; a schema test asserts no float or
   decimal column exists anywhere (ADR-007).
2. Every financial entity carries owner, trust level, source/provenance,
   `created_at`, `updated_at`, and links to its audit trail.
3. Transactions are immutable at the persistence layer: an update attempt on a
   posted transaction is rejected, and corrections create a new record
   referencing the original (`DOMAIN_MODEL.md` §Audit and Immutability).
4. `household_id` exists, is nullable, is never read by any query, and a
   constraint or test prevents more than one user per household (ADR-025 —
   "Household-ready schema choices do not authorize shared access behavior").
5. Audit events are append-only: an application-role attempt to update or delete
   an audit row fails (TM-13).
6. The database role used by the application is least-privilege and cannot
   `DROP`, alter schema, or read the audit table's protected columns (TM-01).
7. Recurrence helpers implement `actual_due_day = min(due_day, days_in_month)`
   and the anchor-date rules, with unit tests for Feb 28/29, day-30, and day-31.
8. Encryption at rest is enabled for the database and backups, evidenced by
   configuration export, not by assertion.

**Validation and evidence.** Migration apply/rollback transcript; the
no-float schema test output; immutability and audit-append negative-test output;
database role grant export; encryption configuration export; recurrence unit
test results.

**Owner / runtime.** Forge with Ledger approval on entity semantics /
**Claude Code** (schema design spanning entities, audit, provenance, and
authorization is multi-file design work).
**Reviewer.** Ledger (entity correctness), Sentinel (encryption, least
privilege, audit immutability, ADR-025 constraint).
**Human gate.** None beyond G2.

**Traces to.** ADR-005, ADR-006, ADR-007, ADR-011, ADR-025; `DOMAIN_MODEL.md`
in full; `DATA_CLASSIFICATION.md` storage rules; TM-01, TM-13.

---

### PH1-WP-05 — Ledger: financial-engine package

**Objective.** Implement the deterministic current-state engine: current
balance, upcoming obligations, available balance, safety threshold.

**Scope.** `FINANCIAL_ENGINE.md` §1.1–§1.4 exactly, as pure functions over
`domain-types` with no I/O, no clock access except an injected date, and no
database dependency.

**Explicitly out of scope.** Forecasting or projection of any kind (WP-06).
Recommendations (WP-07). Interest, utilization, minimum payments (Phase 1.1).
Multi-account aggregation — `FINANCIAL_ENGINE.md` §1.1 step 4 explicitly forbids
aggregating.

**Likely files.** `packages/financial-engine/src/**`, `packages/financial-engine/test/**`.

**Dependencies.** WP-03 (fixtures, rules), WP-04 (types). Blocks WP-06.

**Acceptance criteria.**
1. All §1.1–§1.4 outputs match the approved fixtures exactly at integer-cent
   precision.
2. Every documented edge case has a test: no account; negative balance
   (overdraft); unverified account; zero obligations; multiple obligations on
   one date; `due_day` 31 in a 30-day month; `due_day` 29/30/31 in February,
   leap and non-leap.
3. Available balance subtracts the safety threshold from *available*, never from
   the stored balance (`FINANCIAL_ENGINE.md` §1.3 "Important").
4. The package has zero runtime dependencies on the API, database, network,
   filesystem, clock, or randomness — enforced by a dependency-boundary test.
5. Given identical inputs the outputs are byte-identical across 100 runs
   (determinism assertion).
6. The C-09 trust rule is implemented as decided in WP-03 and both branches are
   covered.

**Validation and evidence.** Full test output with pass/fail/skip counts;
fixture-conformance report naming the fixture-set version; coverage report;
dependency-boundary test output.

**Owner / runtime.** Ledger (correctness authority) / **Codex** — the
specification is explicit and the fixtures pre-exist, which is precisely the
"implementing an already-approved design" shape `agent-routing.md` assigns to
Codex.
**Reviewer.** Ledger approval mandatory before merge (`AGENT_ROSTER.md`: "All
financial math validated by Ledger before deployment"); Nova acceptance.
**Human gate.** None.

**Traces to.** ADR-002, ADR-007; `FINANCIAL_ENGINE.md` §1; NFR-02; M-08, M-09.

---

### PH1-WP-06 — Oracle: forecast-engine package

**Objective.** Implement the 30-day projection, the three scenarios, the
lowest-balance point, and the margin of safety.

**Scope.** `FINANCIAL_ENGINE.md` §2.1–§2.4: daily projection with dated events,
conservative (income +3 days), expected, and optimistic (obligations +2 days)
scenarios, `SAFE`/`TIGHT`/`UNSAFE` assessment, lowest/highest balance and dates,
margin of safety and its percentage.

**Explicitly out of scope.** Verdicts or recommendations (WP-07). Horizons other
than 30 days. Persisting projections — `OPEN_QUESTIONS.md` resolved forecast
strategy as on-demand computation, so nothing is stored.

**Likely files.** `packages/forecast-engine/src/**`, `packages/forecast-engine/test/**`.

**Dependencies.** WP-05 (consumes Ledger output — strictly one-directional).
Blocks WP-07.

**Acceptance criteria.**
1. All 22 in-scope fixtures produce the expected `lowest_balance_cents`,
   `lowest_balance_date`, and `margin_of_safety_cents` exactly (M-09, M-10).
2. Same-date ordering follows the WP-03 rule, the rule is exposed in the output
   so the UI can display it (FR-07), and TV-13 passes.
3. All three scenarios are produced for every projection; the only differences
   between them are the documented timing shifts, verified by a test asserting
   amounts and horizon are unchanged across scenarios.
4. Each projected day carries its events with type, source id, and trust level,
   so FR-07's per-event source inspection is possible without a second query.
5. Edge cases tested: no income; no obligations; neither; income and obligation
   on the same date; multiple obligations on one date; obligation on day 31.
6. No dependency on the API, database, network, clock, or randomness; determinism
   assertion as in WP-05.

**Validation and evidence.** Test output with counts; per-fixture conformance
table; scenario-invariance test output; coverage report.

**Owner / runtime.** Forecast/Oracle domain, under Ledger correctness authority /
**Codex**.
**Reviewer.** Ledger; Nova.
**Human gate.** None.

**Traces to.** ADR-002, ADR-007, ADR-017; `FINANCIAL_ENGINE.md` §2; FR-07; M-10.

---

### PH1-WP-07 — Strategist: decision-engine package

**Objective.** Implement the affordability verdict, timing recommendation, risk
assessment, and confidence calculation.

**Scope.** `FINANCIAL_ENGINE.md` §3.1–§3.4 with the WP-03 canonical verdict enum,
`assumption_trust` definition, rounding rule, and confidence→label bands.
Alternatives generation (buy today / wait until after next income / do not buy).
The income-delay and unexpected-expense stress tests.

**Explicitly out of scope.** Natural-language rendering (WP-12). Any LLM call.
Credit-card, financing, or debt alternatives — `FINANCIAL_ENGINE.md` §3.1 marks
"Finance it" as Phase 1.1.

**Likely files.** `packages/decision-engine/src/**`, `packages/decision-engine/test/**`.

**Dependencies.** WP-05, WP-06, WP-03. Blocks WP-12.

**Acceptance criteria.**
1. Verdict and confidence match the approved fixtures exactly for all in-scope
   vectors, including the boundary vectors TV-14 (purchase exactly equals
   available) and TV-15 (one dollar more).
2. The confidence threshold behavior is exact at the boundary: a fixture at 69
   asks and a fixture at 70 answers, with the WP-03 rounding rule applied.
3. Every returned recommendation carries a traceable reference to the Ledger and
   Oracle outputs it used, sufficient for ADR-014 click-through, with no value
   originating in the decision engine itself.
4. At least one alternative is always present when a verdict is given (FR-08).
5. `primary_risk` classification covers all five documented cases plus null.
6. A negative-balance or uncovered-obligation outcome never produces an
   affirmative verdict (FR-08: "not softened into an affirmative recommendation").
7. Deterministic and I/O-free, as WP-05.

**Validation and evidence.** Fixture conformance report; boundary-test output;
a traceability test proving every emitted number is attributable to an upstream
engine output; coverage report.

**Owner / runtime.** Ledger (correctness) with product review by Archivist on
FR-08 wording / **Codex**.
**Reviewer.** Ledger; Nova.
**Human gate.** None.

**Traces to.** ADR-002, ADR-014, ADR-017, ADR-021; `FINANCIAL_ENGINE.md` §3;
FR-08; NFR-02, NFR-05; M-08, M-11.

---

### PH1-WP-08 — Identity: authentication with MFA baseline, sessions, and recovery

**Objective.** Implement OWASP-aligned authentication with **MFA as a baseline
control** (ADR-022), server-side session management, and a recovery path that
does not become the weakest link.

**Scope.** Registration, login, logout, session lifecycle, password hashing,
breached-password screening, rate limiting and anti-enumeration, MFA enrolment
and challenge, MFA recovery, password reset, email verification, re-authentication
before destructive or bulk-export actions, and the authentication audit events.

**Explicitly out of scope.** Authorization of financial objects (WP-09). Any
household role model (ADR-025). OAuth or bank credentials (ADR-004). Operator or
admin console.

**Likely files.** `apps/api/src/auth/**`, `apps/api/src/common/session/**`,
migration additions for MFA secrets and recovery artifacts.

**Dependencies.** WP-04 (user entity), WP-02 (corrected security baseline —
without C-01 closed, Sentinel would validate against a document that says MFA is
optional). Decision **D-01** (factor types and recovery model). Blocks WP-09,
WP-13.

**Acceptance criteria.**
1. No production authentication path completes without a second factor;
   password-only login is impossible, evidenced by a negative test.
2. MFA secrets and recovery codes are Restricted: encrypted at rest with key
   handling separate from the encrypted values, never logged, never returned
   after enrolment (`DATA_CLASSIFICATION.md` authentication-data row).
3. Passwords are stored only as salted adaptive one-way hashes; a test asserts
   no reversible storage.
4. Reset and verification artifacts are single-use, short-lived, and invalidated
   on use and on credential change.
5. Session identifiers are cryptographically random, stored server-side or
   revocable, rotated after authentication, privilege change, password reset,
   and MFA change; idle and absolute lifetimes are enforced.
6. Cookies are `Secure`, `HttpOnly`, with an appropriate `SameSite`.
7. Login, reset, verification, and MFA-challenge endpoints are rate-limited and
   return generic failures that do not disclose account existence (TM-04).
8. Re-authentication is required before account deletion, bulk export, and
   credential or MFA changes.
9. The full authentication lifecycle emits audit events per
   `SECURITY_ARCHITECTURE.md` §"Required event coverage", with no secret,
   token, or session identifier in any log line.
10. The MFA recovery path is documented with its threat analysis and does not
    permit factor bypass via email alone unless Gerso accepts that risk at D-01.

**Validation and evidence.** Negative test proving password-only login fails;
rate-limit and anti-enumeration test output; reset-token single-use and
expiry test; session rotation and revocation test; redacted audit-log samples;
secret-storage configuration export; dependency vulnerability scan.
All returned to Sentinel — **WP-08 does not approve its own controls** (ADR-024).

**Owner / runtime.** Sentinel (control ownership) with Forge implementing /
**Claude Code** — MFA touches enrolment, challenge, recovery, session, audit,
and UI contracts simultaneously; this is cross-cutting design, not a bounded patch.
**Reviewer.** **Sentinel, independently** (mandatory, ADR-024). Nova acceptance.
**Human gate.** **G3** — Gerso decides D-01 (factor types, recovery model,
recovery residual risk) before implementation begins.

**Traces to.** **ADR-022**, ADR-024; `SECURITY_ARCHITECTURE.md`
§"Authentication and session management"; TM-04, TM-12; `security-review.md` §1.

---

### PH1-WP-09 — API surface: financial records, ownership authorization, validation

**Objective.** Expose the MVP financial operations over authenticated HTTP with
deny-by-default, server-derived, object-level authorization.

**Scope.** CRUD for account, income, and obligation; the correction flow (FR-10);
conflict surfacing (FR-05); forecast and affordability endpoints wrapping
WP-05/06/07; server-side allowlist schema validation; CSRF defence; the
route/tool authorization matrix; per-route audit events; in-product notification
state (FR-12).

**Explicitly out of scope.** Authentication itself (WP-08). Audit export and
account deletion (WP-10). Koban and any LLM path (WP-11/12). Any endpoint
accepting a user, household, account-owner, or tenant identifier from the client.

**Likely files.** `apps/api/src/accounts/**`, `apps/api/src/income/**`,
`apps/api/src/obligations/**`, `apps/api/src/forecast/**`,
`apps/api/src/notifications/**`, `apps/api/src/common/**`.

**Dependencies.** WP-04, WP-05, WP-06, WP-07, WP-08. Blocks WP-10, WP-12, WP-13.

**Acceptance criteria.**
1. Every endpoint derives the subject from the authenticated session; a test
   proves that supplying any client-side identity or ownership parameter is
   ignored or rejected (TM-05, ADR-025).
2. A second test identity cannot read, modify, or enumerate the first identity's
   records on **any** route — a full route-by-route negative matrix, not a sample.
3. Deny-by-default: a route with no explicit authorization decision fails closed;
   a test asserts no route reaches a handler without one.
4. All input is validated server-side against allowlist schemas with type,
   length, range, and canonicalization; unexpected fields are rejected (TM-01).
5. All persistence is parameterized; a test or lint rule forbids raw query
   string concatenation (TM-01).
6. No state change occurs via `GET`; CSRF defence is present and tested
   cross-origin (TM-03).
7. Corrections never overwrite: FR-10's before/after presentation, cancel-is-a-noop,
   and confirm-triggers-recalculation are each tested, and a correction that
   creates a conflict raises FR-05 rather than silently choosing (C-09-adjacent).
8. Monetary values appear in no URL, query string, error message, or telemetry
   (`DATA_CLASSIFICATION.md` transmission rules).
9. Every financial create, update, correction, and read-for-export emits an audit
   event with actor, target, correlation id, and outcome.
10. Pagination and rate limits exist on every list endpoint (TM-11).

**Validation and evidence.** The complete route authorization matrix; the
second-identity negative test output; injection and CSRF test results; schema
rejection tests; redacted audit samples; a scan of responses and logs proving no
sensitive value leakage. Returned to Sentinel.

**Owner / runtime.** Forge / **Claude Code** for the authorization matrix and
module architecture; **Codex** is appropriate for the per-resource CRUD handlers
once that matrix is approved. Recommend Claude Code as primary with a Codex
sub-assignment for the repetitive handlers.
**Reviewer.** **Sentinel** (authorization, validation, audit); Ledger (that the
API does not alter engine outputs); Nova.
**Human gate.** None beyond G3.

**Traces to.** ADR-014, ADR-025; FR-02, FR-03, FR-04, FR-05, FR-07, FR-10, FR-12;
TM-01, TM-02, TM-03, TM-05, TM-11; `SECURITY_ARCHITECTURE.md` §Authorization.

---

### PH1-WP-10 — Audit logging, user export, and account deletion

**Objective.** Make access and change accountable, and make the user's data
portable and erasable, with evidence.

**Scope.** The audit-event pipeline and its required field set; log redaction;
retention configuration (24 months security/financial-change, 12 months
authentication telemetry); user-facing export of financial data and audit
history with re-authentication, asynchronous generation, scoping, expiry, and
its own audit event; account deletion and purge including the backup lifecycle;
CSV formula-injection neutralisation on export.

**Explicitly out of scope.** Analytics, metrics, or product telemetry (WP-16).
Backup infrastructure itself (WP-14) — this package consumes it and proves the
deletion path reaches it.

**Likely files.** `apps/api/src/audit/**`, `apps/api/src/export/**`,
`apps/api/src/account-lifecycle/**`, retention configuration,
`docs/security/RETENTION_SCHEDULE.md` (new).

**Dependencies.** WP-04, WP-08, WP-09, WP-14 (backup lifecycle). Decision **D-06**
(retention schedule approval). Blocks WP-15.

**Acceptance criteria.**
1. Every event class in `SECURITY_ARCHITECTURE.md` §"Required event coverage" is
   emitted, with every required field (UTC timestamp, type, outcome, actor,
   target type and opaque id, correlation id, context, change reference).
2. No log line anywhere contains a password, token, session id, encryption key,
   full prompt, or unnecessary financial value — proven by a redaction test over
   generated log output, not by policy statement (TM-13).
3. Audit records cannot be modified or deleted by the application role; the
   attempt is itself audited.
4. Export requires re-authentication, is scoped to the owner, expires, is
   audited, and cannot be retrieved by a second identity after expiry (TM-11).
5. Exported CSV neutralises formula-leading cells (TM-06).
6. Deletion purges active stores, is verified by a post-deletion query returning
   nothing for the subject, and has a documented and tested backup-expiry path;
   legal/security holds override (`DATA_CLASSIFICATION.md` retention baseline).
7. Retention configuration matches the approved schedule and is evidenced by
   configuration export.
8. Log-delivery failure raises an alert (TM-13).

**Validation and evidence.** Redacted audit samples per event class; tamper-denial
test output; export test including the second-identity and expiry cases;
deletion verification transcript including backup lifecycle; retention
configuration export; log-delivery alert test. Returned to Sentinel.

**Owner / runtime.** Sentinel (control ownership), Forge implementing /
**Codex** — requirements are enumerated and testable; this is bounded
implementation with clear acceptance criteria.
**Reviewer.** **Sentinel, independently**; Archivist (evidence indexing); Nova.
**Human gate.** **D-06** (retention schedule) must be approved before release.

**Traces to.** ADR-006, ADR-013, ADR-024; `SECURITY_ARCHITECTURE.md`
§"Audit logging and user export"; `DATA_CLASSIFICATION.md` retention baseline;
TM-06, TM-11, TM-13; `security-review.md` §6.

---

### PH1-WP-11 — LLM trust-boundary policy and data contract *(design only)*

**Objective.** Define, before any provider code exists, exactly what may cross
the external-LLM boundary, in what form, under what controls — without selecting
a provider and without authorizing identifiable production financial data.

**Scope.** The full Section 8 design: the egress data allowlist; the
tokenization/minimization scheme; retention and privacy requirements a provider
must satisfy before Mode B is permitted; provider access control and egress
restriction; the logging contract; the deny-by-default enforcement model and its
kill switch; the enforcement test corpus specification including a prompt-injection
corpus; and the Mode A degradation behavior.

**Explicitly out of scope.** **Selecting a provider.** Authorizing identifiable
production financial data. Writing provider adapter code (WP-12). Negotiating
contracts.

**Likely files.** `docs/security/LLM_TRUST_BOUNDARY.md` (new),
`docs/security/THREAT_MODEL.md` (TM-08 and TM-10 refinement),
possibly a new ADR recording the tokenized-egress decision.

**Dependencies.** WP-02 (data classification consistency). Independent of all
code — **can start immediately, in parallel with WP-01**. Blocks WP-12.

**Acceptance criteria.**
1. A field-level allowlist exists: every field is either explicitly permitted to
   cross the boundary or denied, with no unenumerated default (ADR-023
   "deny-by-default").
2. The scheme by which authoritative monetary values reach the user without the
   provider receiving them is specified and testable.
3. Retention, training-use, subprocessor, incident-notification, and deletion
   requirements a provider must meet are stated as pass/fail criteria a future
   provider evaluation can be scored against.
4. The document states plainly that provider selection alone does not authorize
   identifiable data processing, and names Gerso as the only approver
   (ADR-023 consequences).
5. Mode A (no external provider egress of production financial data) is fully
   specified as the default, including what the user experience degrades to.
6. The enforcement test corpus is specified: allowlist-violation rejection,
   tokenization-leak detection, prompt-injection resistance, tool-denial, and
   kill-switch behavior.
7. The logging contract states exactly which metadata is recorded and explicitly
   forbids default prompt/response persistence (TM-10, `DATA_CLASSIFICATION.md`
   Koban handling).
8. Sentinel has reviewed and signed the document.

**Validation and evidence.** Sentinel review record; a traceability table from
each of TM-08, TM-09, TM-10 to the control that addresses it; the allowlist
itself as a machine-readable schema that WP-12 can consume directly.

**Owner / runtime.** **Sentinel** (trust boundary and data classification are
Sentinel's owned domain) with Koban contributing the orchestration constraints /
**Claude Code** — policy design across threat model, data classification, and
product requirements.
**Reviewer.** Nova; Ledger confirms the tokenization scheme cannot corrupt
authoritative values.
**Human gate.** **G4** — Gerso approves the boundary policy and decides **D-02**
(whether Phase 1 uses an external provider at all).

**Traces to.** **ADR-023**, ADR-003, ADR-013; TM-08, TM-09, TM-10;
`DATA_CLASSIFICATION.md` §"Koban and provider handling";
`SECURITY_ARCHITECTURE.md` trust-boundary diagram.

---

### PH1-WP-12 — Koban orchestration, tool contracts, and boundary enforcement

**Objective.** Implement the orchestrator that translates a user question into
deterministic engine calls and renders an FR-09-compliant explanation, with the
WP-11 boundary enforced in code and provable by test.

**Scope.** The tool contract layer (strict schemas, server-side authorization
bound to the session subject, allowlist, denial audit events); the orchestration
flow Koban → Ledger → Oracle → Strategist; the six-component explanation
renderer; citation binding per ADR-014; the egress broker implementing the WP-11
allowlist with fail-closed rejection; the provider abstraction (ADR-003) with **no
provider selected**; the kill switch; treating all model output as untrusted.

**Explicitly out of scope.** Selecting or contracting a provider. Any calculation
— Koban performs no arithmetic (ADR-002, PHILOSOPHY). Sending any non-allowlisted
field. Executing any financial action (NFR-05).

**Likely files.** `apps/api/src/koban/**`, `packages/llm-provider/**` (abstraction
plus a deterministic local/test adapter only), `apps/api/src/koban/policy/**`.

**Dependencies.** WP-11 (policy), WP-05/06/07 (tools), WP-09 (authorization),
WP-03 (verdict enum, confidence bands). Blocks WP-13.

**Acceptance criteria.**
1. Koban emits no monetary value that did not come verbatim from an engine
   output — asserted by a test comparing every numeric token in the response
   against the engine result set (this is the structural guarantee for M-11).
2. Every response contains all six explanation components (FR-09) and at least
   one traceable citation; a response with missing or conflicting critical data
   contains no verdict (FR-06, FR-09).
3. The egress broker rejects any payload containing a field outside the WP-11
   allowlist, fails closed on schema mismatch, and audits the denial.
4. A property test asserts that no real monetary value or identifier from the
   database appears in any outbound provider payload.
5. The prompt-injection corpus from WP-11 produces zero policy violations, zero
   unauthorized tool invocations, and zero context disclosure (TM-08).
6. Tool calls are allowlisted, strictly schema-validated, bound to the session
   subject, and cannot reach arbitrary database, network, filesystem, or shell
   capability (TM-08); denied calls are audited.
7. Model output is rendered as data, never as executable markup (TM-02).
8. The kill switch disables all provider egress and the system degrades to Mode A
   without loss of the deterministic verdict.
9. Confidence is presented as a HIGH/MEDIUM/LOW label externally, with the
   numeric value available only in expanded detail (gate resolution #1, C-10).
10. No path can execute, schedule, or claim to have executed a financial
    transaction (NFR-05, FR-09).

**Validation and evidence.** Numeric-fidelity test output; egress-rejection and
tokenization-leak test output; the prompt-injection corpus run with per-case
results; tool-denial traces; kill-switch test; six-component completeness test
over a response sample; citation-binding test. Returned to Sentinel.

**Owner / runtime.** Koban (AI safety domain) with Sentinel co-review /
**Claude Code** — the abstraction, the injection surface, and the enforcement
broker are design-heavy and span many components.
**Reviewer.** **Sentinel, independently** (provider handling is an explicit
ADR-024 validation item); Ledger (numeric fidelity); Nova.
**Human gate.** **G4** must have closed. If D-02 selects Mode B, a **second**
Gerso approval is required before any real provider call carries production data
(ADR-023: "requires explicit future approval").

**Traces to.** **ADR-023**, ADR-002, ADR-003, ADR-014; FR-06, FR-09; NFR-02,
NFR-03, NFR-05; TM-08, TM-09, TM-10; M-11.

---

### PH1-WP-13 — Web experience: onboarding, forecast, correction, explanation

**Objective.** Deliver the responsive single-user web experience that makes the
five journeys completable and the explanation legible.

**Scope.** J-01 onboarding (checking, paycheck, obligation) with resume; MFA
enrolment and challenge UI; J-02 affordability conversation; J-03 bill entry and
edit; J-04 forecast review with per-event source and trust inspection and the
same-date ordering disclosure; J-05 correction with supersession messaging;
FR-05 trust and conflict presentation; FR-12 in-product notices; ADR-014
click-through explanation; accessibility per NFR-04; empty, incomplete, and
error states.

**Explicitly out of scope.** Any calculation in the browser — the frontend
converts cents to display dollars and nothing else (`DOMAIN_MODEL.md` §Display
Conversion). Any household or sharing affordance. Push, email, or SMS
notification. Budgeting, categories, calendar, goals.

**Likely files.** `apps/web/**`.

**Dependencies.** WP-08 (auth), WP-09 (API), WP-12 (Koban endpoint), WP-03
(labels and verdict vocabulary). Blocks WP-16.

**Acceptance criteria.**
1. All five journeys are completable end to end on both a desktop and a mobile
   viewport (ADR-008, NFR-04).
2. Minimum setup to first-question-ready is achievable within five minutes by an
   unassisted user in pilot testing (NFR-01, M-02) — formally measured in WP-16.
3. Facts and assumptions are visually distinguished, and the distinction is not
   conveyed by colour alone; validation status has a text equivalent (NFR-04).
4. Every displayed financial value shows its source type and trust state on
   inspection (FR-05).
5. Conflicting values are shown side by side with a resolution prompt, and the
   dependent conclusion is blocked until resolved (FR-05).
6. A correction shows current and proposed values before confirmation; cancel
   changes nothing; confirm visibly refreshes affected results and marks the
   prior answer superseded (FR-10).
7. Confidence is shown as HIGH/MEDIUM/LOW with rationale; the numeric value
   appears only in expanded detail (C-10).
8. No screen uses guarantee language for a projection (NFR-05).
9. No screen offers or implies money movement, scheduling, or execution (NFR-05).
10. Financial values never appear in URLs; no financial value is written to
    browser storage or client telemetry (`DATA_CLASSIFICATION.md`).
11. The WCAG target chosen at **D-03** is met and evidenced by an automated and
    a manual audit.

**Validation and evidence.** Journey walkthrough recordings or transcripts for
J-01…J-05 on both viewports; accessibility audit output (automated plus manual
keyboard and screen-reader pass); XSS test results for rendered Koban output,
obligation names, and error messages (TM-02); CSP header verification; a check
confirming no sensitive value in URL, storage, or telemetry.

**Owner / runtime.** Interface (UX and accessibility domain) / **Claude Code** —
many components, many states, cross-cutting explanation and accessibility
requirements.
**Reviewer.** Archivist (FR/journey conformance), Sentinel (XSS, CSP, client-side
data handling), Nova.
**Human gate.** **D-03** (WCAG target) before completion.

**Traces to.** ADR-008, ADR-014; FR-01…FR-12; NFR-01, NFR-03, NFR-04, NFR-05;
J-01…J-05; TM-02.

---

### PH1-WP-14 — Platform: infrastructure, secrets, encryption, backup and restore

**Objective.** Stand up the deployment target with the encryption, secret
management, network, supply-chain, and recovery controls the security baseline
requires — and prove restore works.

**Scope.** Infrastructure as code for Azure Container Apps and the managed
PostgreSQL instance; Vercel frontend configuration; GitHub Actions OIDC (no
stored cloud credentials); secret and key management; TLS and HSTS; egress
restriction for the API including the provider egress allowlist from WP-11;
backup configuration; **a tested restore**; RPO and RTO; image pinning,
dependency and container scanning, and branch protection; environment separation
with no production data in non-production.

**Explicitly out of scope.** Kubernetes (ADR-012 defers it). Application code.
Production release approval (G6). Provider contracts.

**Likely files.** `infra/**` (Bicep or Terraform), `.github/workflows/deploy-*.yml`,
environment configuration, `docs/runbooks/` entries for deploy, rollback, and restore.

**Dependencies.** WP-01. Runs in parallel with the application packages.
Blocks WP-10 (backup lifecycle) and WP-15.

**Acceptance criteria.**
1. No cloud credential is stored in the repository or in CI; GitHub Actions
   authenticates to Azure by OIDC (ADR-012).
2. All secrets live in a managed secret store, scoped to the consuming workload,
   with a documented rotation procedure; secret scanning is enabled and clean
   (`security-review.md` §1).
3. TLS 1.2 minimum (1.3 preferred) on every external endpoint, HSTS enabled,
   weak protocols and ciphers disabled, certificates managed and expiry
   monitored — evidenced by an external TLS scan (`security-review.md` §4).
4. Database, storage, and backups are encrypted at rest; backup access is
   authorized separately from application access (`security-review.md` §8).
5. **A restore has actually been performed and evidenced.** An untested backup is
   not a control. RPO and RTO are stated and accepted by the system owner.
6. No administrative interface or database port is reachable from the internet;
   egress from the API is restricted, and the provider egress allowlist is
   enforced at the network layer as defence in depth (`security-review.md` §3).
7. Images are pinned by digest or a controlled tag policy; no unpinned `latest`
   in production; CI fails on critical dependency or container vulnerabilities
   absent a recorded exception (`security-review.md` §7).
8. Deployed artifacts are traceable to a commit and a pipeline run; branch
   protection and mandatory review are enforced on the production branch.
9. Production and non-production are separated, and no production data exists in
   any non-production environment.
10. A rollback procedure is documented and exercised.

**Validation and evidence.** IaC plan and apply output; TLS scan; encryption and
backup configuration exports; **restore test record with outcome and timing**;
port and egress inventory; secret store configuration and RBAC bindings; CI scan
and gate configuration; branch protection export; rollback exercise record.
Returned to Sentinel.

**Owner / runtime.** **Shinobi** (infrastructure domain; `orchestration.md`:
"Shinobi must not approve its own security posture") / **Claude Code** for the
IaC design, with **Codex** appropriate for bounded module implementation once the
design is approved.
**Reviewer.** **Sentinel, independently**; Nova.
**Human gate.** **G5** — Gerso approves cloud spend, region and data residency
(**D-04**) before resources are created. `agent-routing.md` requires escalation
for "cost commitments" and "production deployment".

**Traces to.** ADR-012, ADR-013, ADR-024; `SECURITY_ARCHITECTURE.md`
§"Encryption and key handling"; TM-14, TM-15; `security-review.md` §1, §3, §4,
§5, §7, §8.

---

### PH1-WP-15 — Sentinel independent pre-release security validation

**Objective.** Independently verify that the controls ADR-024 names are
**deployed and working** — not merely designed — and produce the release
security recommendation.

**Scope.** Independent validation of authentication (including MFA),
authorization, encryption, auditing, backup and restore, export and delete, and
LLM-provider handling. Review against all eight `security-review.md` dimensions.
Severity classification, required controls versus recommended improvements,
residual-risk statement, and exception recommendations.

**Explicitly out of scope.** **Implementing or remediating anything.**
`orchestration.md`: "Sentinel should normally review implementation independently
and should not modify the implementation being reviewed." Also out of scope:
granting production release approval — Sentinel recommends; Gerso approves.

**Likely files.** `docs/security/RELEASE_VALIDATION_PH1.md` (new), an evidence
index, and finding records. **No application, infrastructure, or test file.**

**Dependencies.** WP-08, WP-09, WP-10, WP-12, WP-13, WP-14 — every evidence
producer must have returned its package. Blocks the release gate.

**Acceptance criteria.**
1. Every control named in ADR-024 has an independent verification result:
   authentication, authorization, encryption, auditing, backup/restore,
   export/delete, provider handling.
2. Each of the eight `security-review.md` dimensions is assessed or explicitly
   scoped out with rationale.
3. No control is marked verified on the strength of an implementer's assertion
   alone; each cites evidence Sentinel independently reproduced or inspected.
4. Every finding carries a severity, evidence, and a named remediation owner.
5. Required controls are separated from recommended improvements.
6. An explicit residual-risk statement names what remains, why, who accepts it,
   and when it is next reviewed. Silence is not acceptance.
7. The report follows the `security-review.md` §"Review output format" eight-part
   structure.
8. Any control that cannot be verified is stated as unverified, not assumed —
   and blocks release unless Gerso explicitly accepts the residual risk
   (ADR-024).

**Validation and evidence.** The review document itself; the evidence index
mapping each control to the artifact that proves it; reproduction commands or
transcripts for the checks Sentinel performed directly.

**Owner / runtime.** **Sentinel** — dispatched to the real `sentinel` Hermes
profile via `scripts/dispatch-specialist.sh`, per `agent-routing.md`; **not**
`delegate_task`, which is a disclosed emergency fallback only. **Codex** is
recommended as an independent second reviewer for bounded control verification
(`agent-routing.md`: "performing an independent second review"), but Codex must
not be the sole validator of any ADR-024 control.
**Reviewer.** Nova validates that evidence is real and identity is confirmed
before advancing status.
**Human gate.** **G6** — Gerso grants or withholds production release approval on
the strength of this report.

**Traces to.** **ADR-024**, ADR-013; `security-review.md` in full;
`SECURITY_ARCHITECTURE.md` §"Compliance readiness and evidence";
`THREAT_MODEL.md` §"Residual risk acceptance"; `orchestration.md` §Sentinel.

---

### PH1-WP-16 — Release readiness: metrics instrumentation and moderated validation

**Objective.** Prove the product gates in `SUCCESS_METRICS.md` are met, with
denominators, before release is recommended.

**Scope.** Privacy-aware instrumentation for M-02 and M-06; execution of the
moderated validation study for M-01 through M-07 using the survey prompts
`SUCCESS_METRICS.md` specifies; execution and reporting of the M-08 through M-12
accuracy gates against the WP-03 fixture set; the release-readiness record.

**Explicitly out of scope.** Any security validation (WP-15). Any product change
beyond instrumentation. Combining survey items into a composite "financial
confidence score" — `SUCCESS_METRICS.md` forbids this without separate review.

**Likely files.** `docs/product/RELEASE_READINESS_PH1.md` (new), instrumentation
in `apps/web` and `apps/api` (sequenced strictly after WP-13 to avoid concurrent
ownership of `apps/web`).

**Dependencies.** WP-13, and WP-05/06/07 for the accuracy gates. Runs in parallel
with WP-15.

**Acceptance criteria.**
1. Every launch-gate metric (M-01, M-02, M-03, M-04, M-05, M-07, M-08, M-09,
   M-10, M-11, M-12) has a reported result with its eligible population,
   completed sample, and exclusions — "no metric without a denominator".
2. M-08 reports 100% pass with zero unexplained skips against the versioned,
   domain-approved fixture set, and names that version.
3. M-11 reports 100% Koban value fidelity over the sampled responses.
4. Moderated-study results, test results, and live-product behavior are reported
   separately (`SUCCESS_METRICS.md` measurement principle 4).
5. Instrumentation collects no Restricted financial value and no free-text
   financial content; the collected field list is enumerated and Sentinel-reviewed.
6. Any target revision carries date, owner, rationale, and retained history
   (principle 6).

**Validation and evidence.** The metrics report with denominators; the fixture
run output and version; the moderated-study protocol and anonymized results; the
instrumentation field inventory with Sentinel's review note.

**Owner / runtime.** Nova coordinating, Archivist recording, with human
moderation for the usability study / **Codex** for the instrumentation patch;
the study itself is human work no runtime performs.
**Reviewer.** Sentinel (instrumentation privacy); Ledger (accuracy gate);
Archivist (evidence integrity — must not invent results).
**Human gate.** **G6**, jointly with WP-15.

**Traces to.** ADR-017; NFR-01, NFR-02, NFR-03; M-01…M-13;
`SUCCESS_METRICS.md` §"Accuracy evidence requirements".

---

## 5. Dependency graph, critical path, and parallelization

### 5.1 Graph

```
WP-01 Monorepo ──┬─────────────────────────────────────────────┐
                 │                                             │
WP-02 Baseline ──┼──► WP-03 Fixtures ──► WP-04 Schema ──┐      │
      (parallel) │         │                    │       │      │
                 │         │                    ▼       │      │
                 │         └──────────────► WP-05 Ledger        │
                 │                              │               │
                 │                              ▼               │
                 │                          WP-06 Oracle        │
                 │                              │               │
                 │                              ▼               │
                 │                        WP-07 Strategist      │
                 │                              │               │
                 ├──► WP-08 Auth+MFA ──────────►│               │
                 │        (needs WP-04)         │               │
                 │                              ▼               │
                 │                         WP-09 API ──► WP-10 Audit/Export
                 │                              │               │
WP-11 LLM Policy ├──────────────────────► WP-12 Koban           │
   (parallel,    │                              │               │
    start now)   │                              ▼               │
                 │                        WP-13 Web             │
                 │                              │               │
                 └──► WP-14 Platform ───────────┤               │
                            (parallel)          │               │
                                                ▼               ▼
                              WP-15 Sentinel validation  ∥  WP-16 Release readiness
                                                │               │
                                                └───► G6 Gerso release approval
```

**No cycles.** Verified by construction: every edge points from a lower-numbered
prerequisite to a higher-numbered dependent, with the sole exception of
WP-10 → WP-14 (backup lifecycle), which is a *forward* dependency on a package
that starts in parallel at the beginning; WP-14 does not depend on WP-10, so no
cycle exists. WP-16's instrumentation touches `apps/web`, owned by WP-13; this is
resolved by **strict sequencing**, not by shared ownership.

### 5.2 Critical path

```
WP-01/WP-02 → WP-03 → WP-04 → WP-05 → WP-06 → WP-07 → WP-09 → WP-12 → WP-13 → {WP-15, WP-16} → G6
```

The engine chain (WP-05 → WP-06 → WP-07) is irreducibly serial: `FINANCIAL_ENGINE.md`
mandates one-directional flow, and each engine consumes the previous one's output.

**Highest-leverage compressions**, in order:
1. **Start WP-11 on day one.** It depends only on WP-02 and is otherwise
   code-independent. It is a prerequisite for WP-12, which sits on the critical
   path. Deferring it is the single most likely cause of a late-phase stall.
2. **Run WP-14 in parallel from the start.** It shares no files with any
   application package and gates WP-15.
3. **Close D-01 and D-05 before the first wave completes.** WP-08 cannot start
   without D-01, and WP-02 cannot close without D-05.
4. **WP-03 is the true gate, not WP-01.** Three engines and the release gate all
   depend on it, and it is the package most likely to surface further
   contradictions.

### 5.3 Safe parallelization and file ownership

No two packages may modify the same path concurrently (`agent-routing.md`:
"Do not assign multiple agents to modify the same working tree concurrently
unless they have separate Git worktrees or clearly isolated files").

| Package | Exclusive paths |
|---|---|
| WP-01 | repository root config, `tsconfig*`, `.github/workflows/ci.yml`, workspace `package.json` stubs |
| WP-02 | `docs/**` **except** `docs/architecture/FINANCIAL_TEST_VECTORS.md`, `docs/architecture/FINANCIAL_ENGINE.md`, `docs/security/LLM_TRUST_BOUNDARY.md` |
| WP-03 | `docs/architecture/FINANCIAL_TEST_VECTORS.md`, `docs/architecture/FINANCIAL_ENGINE.md`, `packages/financial-fixtures/**` |
| WP-04 | `packages/domain-types/**`, `apps/api/prisma/**` |
| WP-05 | `packages/financial-engine/**` |
| WP-06 | `packages/forecast-engine/**` |
| WP-07 | `packages/decision-engine/**` |
| WP-08 | `apps/api/src/auth/**`, `apps/api/src/common/session/**` |
| WP-09 | `apps/api/src/{accounts,income,obligations,forecast,notifications,common}/**` |
| WP-10 | `apps/api/src/{audit,export,account-lifecycle}/**` |
| WP-11 | `docs/security/LLM_TRUST_BOUNDARY.md`, TM-08/TM-10 sections |
| WP-12 | `apps/api/src/koban/**`, `packages/llm-provider/**` |
| WP-13 | `apps/web/**` |
| WP-14 | `infra/**`, `.github/workflows/deploy-*.yml`, `docs/runbooks/**` |
| WP-15 | `docs/security/RELEASE_VALIDATION_PH1.md`, evidence index — **read-only elsewhere** |
| WP-16 | `docs/product/RELEASE_READINESS_PH1.md`; instrumentation only after WP-13 closes |

**Contention points to manage explicitly:**
- WP-02 and WP-03 both touch `docs/`. The carve-out above is mandatory; state it
  in both assignments.
- WP-08, WP-09, and WP-10 all live under `apps/api/src/`. They are disjoint by
  module directory, but all three touch the shared module registration file —
  sequence WP-08 → WP-09 → WP-10, or use worktree isolation with a designated
  integrator (`agent-routing.md` §"Parallel work rules").
- WP-13 and WP-16 both touch `apps/web`. Strict sequencing only.

**Safe concurrent sets:**
- Wave A: `{WP-01, WP-02, WP-11, WP-14}` — fully disjoint.
- Wave B: `{WP-03, WP-04}` then `{WP-05}` — WP-04 and WP-03 are disjoint.
- Wave C: `{WP-06 → WP-07}` serial, concurrent with `{WP-08}`.
- Wave D: `{WP-09 → WP-10}` serial, concurrent with `{WP-12}` once WP-07 lands.
- Wave E: `{WP-13}`, then `{WP-15, WP-16}` concurrent.

---

## 6. Claude Code versus Codex routing

Applying `agent-routing.md` §"Claude Code versus Codex": Claude Code when the
challenge is **understanding and designing**; Codex when it is **implementing and
validating a clearly defined change**.

| WP | Domain owner | Runtime | Why |
|---|---|---|---|
| WP-01 | Forge | **Claude Code** | Workspace layout must resolve C-08 and set boundaries every later package inherits. Design, not scaffolding. |
| WP-02 | Archivist | **Claude Code** | Seventeen contradictions across ~20 documents. Long-context cross-document reconciliation — the canonical Claude Code shape. |
| WP-03 | Ledger | **Claude Code** | Three conflicting definitions of `assumption_trust`, two rounding rules, three verdict vocabularies. Requires judgement, then mechanical fixture emission. |
| WP-04 | Forge + Ledger | **Claude Code** | Schema spans entities, audit, provenance, immutability, and the ADR-025 constraint together. |
| WP-05 | Ledger | **Codex** | Specification is explicit (`FINANCIAL_ENGINE.md` §1) and fixtures pre-exist. Bounded, test-driven. |
| WP-06 | Forecast | **Codex** | Same: §2 is fully specified; fixtures define acceptance. |
| WP-07 | Ledger | **Codex** | Same: §3 plus the WP-03 canonical enum. |
| WP-08 | Sentinel + Forge | **Claude Code** | MFA is cross-cutting: enrolment, challenge, recovery, session, audit, UI contract. Not a bounded patch. |
| WP-09 | Forge | **Claude Code** primary, **Codex** sub-assignment | Authorization matrix and module architecture need design; the repetitive per-resource handlers are ideal Codex work once approved. |
| WP-10 | Sentinel + Forge | **Codex** | Requirements are enumerated and each is directly testable. |
| WP-11 | Sentinel | **Claude Code** | Policy design across threat model, data classification, and product requirements. |
| WP-12 | Koban + Sentinel | **Claude Code** | Provider abstraction, injection surface, and the fail-closed egress broker are design-heavy and span components. |
| WP-13 | Interface | **Claude Code** | Many components and states; explanation and accessibility cut across all of them. |
| WP-14 | Shinobi | **Claude Code** design, **Codex** bounded modules | IaC topology and control placement need design; individual modules are bounded. |
| WP-15 | **Sentinel** (real Hermes profile via dispatcher) | Sentinel; **Codex** as independent second reviewer | ADR-024 requires independence. Codex fits "performing an independent second review" but must not be the sole validator of any ADR-024 control. |
| WP-16 | Nova + Archivist | **Codex** for instrumentation; study is human work | Instrumentation is a bounded patch; moderated usability research has no runtime. |

**Standing constraint.** Per `agent-routing.md`, WP-15 must be dispatched to the
real `sentinel` Hermes profile through `scripts/dispatch-specialist.sh` with
transport evidence recorded in `transport.json` and the ledger. `delegate_task`
is a disclosed emergency fallback only, and a fallback would have to be labeled
with role simulated, runtime used, reason, and remaining independent review. See
Escalation E-04.

---

## 7. Security review matrix

Columns: the control ADR-024 names → the package that implements it → who
produces the evidence → what Sentinel independently verifies → the gate.

| Control | Implementing WP | Evidence producer | Sentinel verification | Gate |
|---|---|---|---|---|
| **MFA** (ADR-022) | **WP-08** | Forge/Sentinel-owned auth package | Password-only login provably impossible; factor enrolment, challenge, and recovery flows tested; MFA secrets encrypted with separated key handling and never logged; recovery path cannot bypass the second factor beyond the D-01 accepted risk | G3 → G6 |
| **Authorization** | WP-09 (objects), WP-08 (subject derivation), WP-12 (tool authorization), WP-04 (ADR-025 schema constraint) | Forge; Koban for tools | Full route-by-route second-identity negative matrix; deny-by-default proven by a no-decision-fails-closed test; no client-supplied identity accepted anywhere; no household or cross-user path exists | G6 |
| **Encryption** | WP-14 (transit, at rest, backups), WP-04 (database and field-level), WP-08 (auth material) | Shinobi; Forge | External TLS scan showing 1.2+ and no weak ciphers; HSTS present; encryption configuration exports for database, storage, and backups; key and secret separation confirmed; secret-scan clean | G5 → G6 |
| **Auditing** | WP-10 (pipeline, retention, redaction), WP-09 (financial events), WP-08 (auth events), WP-12 (Koban and provider events) | Forge; Koban | All required event classes present with all required fields; redaction test over generated logs; append-only tamper-denial test; retention configuration export; log-delivery alert test | D-06 → G6 |
| **Backup / restore** | WP-14 (configuration, isolation, restore test), WP-10 (deletion reaches backup lifecycle) | Shinobi | **A restore actually performed**, with record and timing; RPO/RTO stated and owner-accepted; backup access authorized separately from application access; recovery path has no circular dependency | G5 → G6 |
| **Export / delete** | WP-10 | Forge | Export requires re-authentication, is owner-scoped, expires, is audited, and is unreachable by a second identity; CSV formula neutralisation; deletion verified in active stores plus a documented and tested backup-expiry path; holds override | G6 |
| **Provider handling** (ADR-023) | **WP-11** (policy) + **WP-12** (enforcement) | Sentinel authors policy; Koban produces enforcement evidence | Allowlist enforced fail-closed; property test proving no real value or identifier reaches an outbound payload; prompt-injection corpus with zero violations; tool-denial traces; kill switch works; logging contract honoured (no default prompt persistence) | G4 → G6 |

**Cross-cutting rule (ADR-024).** No package in this matrix may sign off its own
control. Every implementing package's handoff must state, explicitly, that its
evidence is *submitted to* Sentinel and does not constitute approval.

**Threat-model coverage.** TM-01→WP-04/09; TM-02→WP-09/12/13; TM-03→WP-09;
TM-04→WP-08; TM-05→WP-09; TM-06→WP-10 (export path only, given A-06);
TM-07→deferred with import (D-05); TM-08/TM-09/TM-10→WP-11/12;
TM-11→WP-09/10/14; TM-12→WP-14; TM-13→WP-10; TM-14→WP-14; TM-15→WP-09/14.
**If D-05 puts import back in scope, TM-06 and TM-07 have no owning package and
a new one must be inserted before WP-13.**

---

## 8. LLM trust-boundary plan

This is the Phase 1 design work ADR-023 requires. It selects **no provider** and
authorizes **no identifiable production financial data**.

### 8.1 The tension, stated plainly

FR-09 requires Koban to explain a specific user's specific financial position in
natural language with six components. ADR-023 forbids production financial data
from crossing an external provider boundary by default. `DATA_CLASSIFICATION.md`
classifies balances and transactions as **Restricted**, and classifies a
*combination* of institution, balance, income, and obligations as Restricted
"because aggregation reveals a detailed financial profile" — which is precisely
what an affordability explanation is.

A naive implementation sends the user's balance, paycheck, and rent to a provider
and violates ADR-023 on the first request.

### 8.2 Recommended design: tokenized egress, deny-by-default

**Two modes, with Mode A as the default.**

- **Mode A — no production financial data crosses the boundary.** The
  deterministic engines produce the verdict, and a server-side renderer produces
  the six-component explanation from templates bound to engine outputs. No
  external provider call carries production financial data. The product is fully
  functional; the prose is less fluid.
- **Mode B — bounded tokenized egress.** The provider receives the user's
  question and a *structured, tokenized* representation of the decision, never
  the values themselves.

**The tokenization scheme.** The egress broker replaces every monetary value,
date, and identifier with an opaque placeholder before the payload leaves the
process, and substitutes the authoritative values back into the model's response
server-side:

```
Outbound:  "Verdict SAFER_TO_WAIT. Balance {{M1}}. Next income {{M2}} on {{D1}}.
            Obligation {{OBL1}} of {{M3}} on {{D2}}. Lowest balance {{M4}} on {{D3}}.
            Threshold {{M5}}. Margin {{M6}}. Confidence MEDIUM.
            Constraining event: income timing."
Inbound:   model prose containing {{M1}}, {{M4}}, {{D1}} …
Rendered:  placeholders replaced with authoritative engine values, server-side.
```

This yields three properties at once:

1. **ADR-023 is satisfied structurally.** The provider never receives a balance,
   an amount, a date, a name, an email, an institution, or a record identifier.
   Compliance is a property of the code path, not of a prompt instruction.
2. **M-11 becomes a guarantee rather than a hope.** Koban value fidelity is 100%
   by construction, because the model cannot alter a number it never saw. This
   also structurally satisfies NFR-02's "Koban must reproduce supplied
   authoritative values without alteration" and closes TM-09 (forged citations)
   far more strongly than instruction-following would.
3. **Provider choice becomes low-stakes and reversible**, which is exactly what
   ADR-003's abstraction exists to preserve.

The residual exposure is the user's free-text question, which may itself contain
financial detail. Mitigation: the question is treated as user-authored content
the user chose to type, it is screened for credential-shaped and account-number-shaped
patterns before egress, and the privacy notice states plainly that question text
may be processed by a provider in Mode B. `DATA_CLASSIFICATION.md` already
requires "Do not request users to submit passwords, PINs, MFA seeds, recovery
codes, encryption keys, or full card data in imports or Koban conversations."

### 8.3 The eight required design elements

| Element | Phase 1 requirement |
|---|---|
| **Data allowlist** | An explicit, machine-readable field allowlist. Permitted: user question text (screened), verdict enum, confidence label, risk classification, tokenized placeholders, ordinal relationships, event type labels. Denied by default and never permitted in Phase 1: name, email, user id, account id, account name, institution, any monetary value, any absolute date, transaction descriptions, raw imports, audit records, session or authentication material. Any field not on the allowlist is rejected — **fail closed**. |
| **Minimization / redaction** | A single mandatory egress broker. No component may reach a provider except through it. It validates the payload against the allowlist schema and rejects on any unknown field, any unmasked numeric literal, or any string matching an identifier pattern. Rejection emits an audit event and, in production, degrades to Mode A rather than failing the user's request. |
| **Retention / privacy** | Before Mode B is enabled, the provider must contractually offer: zero retention or a bounded retention window with deletion on request; no use of submitted data for training; an enumerated subprocessor list; incident notification with a stated SLA; and a data-residency commitment consistent with D-04. These are pass/fail criteria for a future evaluation, not a provider recommendation. |
| **Provider access control** | Provider credentials in the managed secret store, scoped to the API workload only, distinct per environment, rotatable. Network egress from the API restricted to the provider endpoint by allowlist (WP-14), so a compromised application cannot exfiltrate to an arbitrary host. Non-production environments hold no production data and use a separate key. |
| **Logging** | Record metadata only: correlation id, template or prompt version, mode, token counts, latency, decision, and any denial reason. **Never** persist rendered prompts or responses containing financial values by default; a documented support or incident purpose plus Restricted-level controls is required for any exception (`DATA_CLASSIFICATION.md` Koban handling). Log prompt-policy violations and denied tool calls. |
| **Deny-by-default enforcement** | Enforcement is code, not prompt text. The broker fails closed. Provider egress is off unless an explicit configuration flag enables it, that flag is auditable, and a kill switch disables it instantly and reverts to Mode A. |
| **Tool authorization** | Tools are allowlisted, strictly schema-validated, and bound to the session subject server-side. No tool grants arbitrary database, network, filesystem, or shell access. Model output never authorizes a tool call. Denied calls are audited (TM-08). |
| **Testability** | Required negative tests: disallowed field → rejected; unmasked numeric literal → rejected; property test asserting no database value appears in any outbound payload; injected instruction in an obligation name → no policy violation and no unauthorized tool call; kill switch → egress ceases and Mode A renders correctly; model output containing markup → rendered as data (TM-02). |

### 8.4 What is deliberately not decided here

- **No provider is named or recommended.** ADR-003's abstraction is implemented;
  the choice remains open.
- **Identifiable production financial data is not authorized** in either mode.
  Mode B carries tokens, not identities. Authorizing identifiable data requires
  a separate explicit Gerso approval per ADR-023 and a new threat-model pass.
- **Whether Phase 1 enables Mode B at all** is decision **D-02**. If Gerso
  chooses Mode A only, WP-12 still builds the abstraction and broker — with no
  live provider — and the phase carries no provider risk whatsoever. This is a
  defensible MVP position and materially reduces WP-15's scope.

---

## 9. Decision register

### 9.1 Decisions required from Gerso

| ID | Decision | Needed by | Blocks | Why it cannot be assumed |
|---|---|---|---|---|
| **D-01** | MFA factor types (TOTP, passkey, email OTP, or a combination) and the account-recovery model, including accepted recovery residual risk. | Before **WP-08** starts | WP-08, WP-13 auth UI, WP-15 MFA validation | ADR-022 mandates MFA but names no method. Recovery design is where MFA baselines usually fail, and `SECURITY_ARCHITECTURE.md` requires recovery abuse controls. Choosing silently would set the account-takeover risk profile without owner consent. |
| **D-02** | Does Phase 1 make **any** external LLM provider call (Mode B tokenized egress), or is the MVP Mode A only? | Before **WP-12** starts; ideally at plan approval | WP-12 scope, WP-13 conversation UX, WP-15 provider validation, provider contracting | ADR-023 makes external processing the exception, not the default. Assignment escalation condition: "A required plan depends on selecting a provider or permitting identifiable production financial data." Mode A is a complete, shippable product. |
| **D-03** | WCAG conformance target (A, AA, or AAA). | Before **WP-13** completes | WP-13 acceptance, WP-16 | `NFR-04` states this explicitly: "The specific WCAG conformance target remains a product decision." `OPEN_QUESTIONS.md` still lists it open. |
| **D-04** | Cloud spend approval, Azure region, and data-residency requirement. | Before **WP-14** creates resources | WP-14, WP-10 backup lifecycle | `agent-routing.md` requires escalation for cost commitments and production deployment. `OPEN_QUESTIONS.md` lists data residency unresolved. |
| **D-05** | Is document/statement upload in Phase 1? (Resolves **C-02**.) | Before **WP-02** closes | WP-02, WP-03 trust ceiling, WP-13 verification UX, whether a new import package is needed | Authoritative sources genuinely conflict: ADR-010 and `MVP_REFINED.md` require it; `PRODUCT_REQUIREMENTS.md`, `PRODUCT_CHARTER.md`, and `MVP_PROOF_POINT.md` exclude it. It changes phase scope by a whole subsystem and caps the maximum reachable trust level at 70%, which changes every confidence output. Escalation **E-02**. |
| **D-06** | Approve the retention schedule (24-month security/financial-change, 12-month authentication telemetry, backup rotation, deletion verification, holds). | Before **WP-10** closes | WP-10, WP-15 | `DATA_CLASSIFICATION.md` §"Retention baseline" explicitly requires Nova, Sentinel, Archivist, and implementation owners to approve a schedule before release. |
| **D-07** | Accept or reject the residual risk Sentinel reports at the release gate. | At **G6** | Production release | ADR-024: missing or failed control evidence blocks release "unless Gerso explicitly accepts the residual risk." |

### 9.2 Decisions delegated to domain owners (recorded, not escalated)

| ID | Decision | Owner | Ratifier | Resolved in |
|---|---|---|---|---|
| DO-01 | Canonical `assumption_trust` definition (C-04) | Ledger | Nova | WP-03 |
| DO-02 | Confidence rounding rule (C-05) | Ledger | Nova | WP-03 |
| DO-03 | Canonical verdict enum and its FR-08 mapping (C-07) | Ledger + Archivist | Nova | WP-03 |
| DO-04 | Sub-70% trust: compute-and-withhold or refuse (C-09) | Ledger | Nova + Sentinel (TM-07) | WP-03 |
| DO-05 | Confidence → HIGH/MEDIUM/LOW band boundaries (C-10) | Archivist | Nova | WP-02/WP-03 |
| DO-06 | Package naming: ADR-019 code names vs ADR-002 brand names (C-08) | Nova | — | WP-01/WP-02 |
| DO-07 | TV-22 (`bank_synced`) inclusion in the Phase 1 M-08 denominator (C-16) | Ledger | Nova | WP-03 |
| DO-08 | Same-date ordering rule and its disclosure (C-13) | Ledger | Archivist | WP-03 |

These are recorded here so that if any is resolved in a way that changes the MVP
boundary or the security baseline, it escalates to Gerso rather than being
absorbed silently.

---

## 10. Recommended first implementation wave

**Not dispatched. Recommended only**, per the assignment's out-of-scope list.

**Wave 1 — four packages, fully disjoint file ownership, no cross-blocking:**

| WP | Owner / runtime | Rationale for inclusion |
|---|---|---|
| **WP-02** Baseline reconciliation | Archivist / Claude Code | **Start first.** Nothing downstream is safe until the security baseline stops contradicting ADR-022 and the scope stops contradicting itself. Sentinel cannot validate WP-08 against a document that says MFA is optional. |
| **WP-11** LLM trust-boundary policy | Sentinel / Claude Code | Code-independent, and it gates WP-12 which sits on the critical path. Starting it late is the most likely cause of a late-phase stall. It also produces the input Gerso needs to decide D-02. |
| **WP-01** Monorepo foundation | Forge / Claude Code | Every code package needs somewhere to land and a CI gate to pass. Needs the C-08 resolution first — sequence the naming decision ahead of directory creation. |
| **WP-14** Platform foundation | Shinobi / Claude Code | Long lead time, shares no files with application work, and gates WP-15. Hold resource creation until D-04. |

**Prerequisites before Wave 1 is dispatched:**
1. Orchestrator validates this plan.
2. Gerso approves the plan (**G1**).
3. **D-05** answered — WP-02 cannot close without it.
4. **DO-06** (package naming) answered — WP-01 cannot create directories without it.
5. **D-04** answered before WP-14 creates any billable resource; WP-14's design
   work can begin beforehand.

**Wave 2 (for planning visibility, not dispatch):** `WP-03` then `WP-04`, with
`WP-08` starting as soon as D-01 lands and WP-04's user entity exists.

**Explicitly not in Wave 1:** every engine package (blocked on WP-03), the API,
Koban, the web application, and both validation packages.

---

## 11. Escalations

Raised under the assignment's escalation conditions rather than resolved by
assumption.

| ID | Escalation | Condition met | Recommendation |
|---|---|---|---|
| **E-01** | `SECURITY_ARCHITECTURE.md:93` and `THREAT_MODEL.md:72`/`:107` contradict ADR-022. The security baseline Sentinel validates against currently says MFA is optional. | "Authoritative sources conflict in a way that changes the security baseline" | Correct in WP-02 before any Sentinel engagement. Sentinel must approve the edit, since Sentinel owns the document. |
| **E-02** | Document/statement upload is simultaneously in and out of the MVP (C-02), and the gate review cites an import journey that does not exist (C-03). | "…changes the MVP boundary" | **D-05.** If in: insert an import package before WP-13 and assign TM-06/TM-07 owners. If out: state the 70% trust ceiling in WP-02 and correct `TRUST_MODEL.md` and ADR-010. |
| **E-03** | The approved financial test vectors — the `NFR-02`/`M-08` release gate — contain values contradicting their own derivations and unresolved authoring notes (C-06), and the confidence formula has three definitions (C-04, C-05). | "…changes the architecture" and "financial correctness ownership" | WP-03 must close before any engine work. Do not treat the current file as an approved fixture set. |
| **E-04** | **No real Ledger runtime profile exists.** `agent-routing.md` allows dispatch only to `sentinel` and `archivist`; `PHASE_0_GATE_REVIEW.md` records that PH0-LDG-001 fell back to `delegate_task` for exactly this reason, and that `FINANCIAL_TEST_VECTORS.md` was ultimately authored by Nova after two API timeouts. Yet `AGENT_ROSTER.md` requires that "all financial math validated by Ledger before deployment" and "no financial changes bypass Ledger review". | "Financial correctness ownership… cannot be assigned under the current roster" | Either register a real Ledger profile, or formally designate the financial-correctness reviewer and record that Ledger review is being performed by a named substitute. **Note the specific risk:** the document with the most defects found in this analysis is the one Nova authored directly while acting as orchestrator — the independent-review gap ADR-024 exists to prevent, applied to financial rather than security controls. |
| **E-05** | ADR-023's deny-by-default versus FR-09's conversational explanation requirement. | "A required plan depends on selecting a provider or permitting identifiable production financial data" | **D-02.** Section 8's tokenized-egress design resolves it without either. Mode A alone is shippable. |
| **E-06** | ADR-019 and ADR-002 specify different package names (C-08), both marked decided. | "A material architecture choice lacks enough evidence for a bounded plan" | **DO-06.** Recommend ADR-019 (later, explicitly "Code (internal, forever)"), and record the supersession in WP-02. |
| **E-07** | Phase 1 is called "Requirements" in `README.md` and `PHASE_0_GATE_REVIEW.md` ("Phase 1 (Requirements and Implementation)"), but `MVP_PROOF_POINT.md` defines a full Phase 1 implementation scope. | Scope ambiguity affecting the whole plan | Assumption **A-01** treats Phase 1 as implementation. Confirm at G1. If Phase 1 is requirements-only, only WP-01/02/03/11 apply. |

**No escalation is a blocker on delivering this plan.** Each is a decision the
orchestrator or Gerso can take with the evidence supplied above.

---

## 12. Validation performed

| Required check | Result |
|---|---|
| Zaifu working tree unmodified | **Confirmed.** `git status --porcelain` identical before and after: ` M docs/planning/DECISION_LOG.md`, ` M docs/planning/PHASE_0_GATE_REVIEW.md`, `?? docs/orchestration/assignments/PH1-CLD-001.md`. HEAD unchanged at `caf8b9c13bce6b7d53feafcaf8797e2b1af3877a`. These three entries were **pre-existing at session start** and were not produced by this analysis. |
| Ninjatronics working tree unmodified | **Confirmed.** Identical before and after: ` M shared/state/assignments.md`, ` M vault/3_Projects/Zaifu.md`, `?? shared/handoffs/PH1-CLD-001/`. HEAD unchanged at `5c4262a554d12b8d70fb85ceadee39170697e689`. Also pre-existing. |
| Every WP has dependencies, acceptance criteria, validation, evidence, owner/runtime, review, and scope boundaries | **Confirmed.** All 16 packages carry all eight fields. |
| Dependency graph has no unexplained cycles | **Confirmed.** §5.1. The only backward-looking edge (WP-10 → WP-14) is a forward dependency on a parallel-start package; WP-14 does not depend on WP-10. The WP-13/WP-16 `apps/web` overlap is resolved by strict sequencing, not shared ownership. |
| All four binding owner decisions represented | **Confirmed.** §3.3 maps ADR-022 → WP-08/G3/D-01; ADR-023 → WP-11/WP-12/G4/D-02/§8; ADR-024 → WP-15/G6 plus a per-package evidence clause; ADR-025 → every package's out-of-scope block, WP-04's schema constraint, WP-09's identity rule. |
| No Phase 1 package includes household or multi-user functionality | **Confirmed.** Prohibited in the common out-of-scope block. WP-04 exposes `household_id` as nullable and unread with a single-user constraint. WP-09 forbids client-supplied tenant identity. WP-15 tests cross-subject denial. |
| No package assumes external LLM access to production financial data | **Confirmed.** WP-11 and WP-12 are deny-by-default with fail-closed enforcement. Mode A is the default. No provider is named. §8.4 states identifiable data is not authorized in either mode. |
| Implementation not performed | **Confirmed.** No file created, modified, or deleted in either repository. No package installed. No branch, worktree, commit, or pull request. No agent dispatched. No provider selected. |

---

## 13. Evidence

### 13.1 Read-only commands used

```bash
# Baseline and final state (identical)
git status --porcelain; git rev-parse HEAD; git rev-parse --abbrev-ref HEAD
git -C /home/gerso/Development/ninjatronics-ai status --porcelain
git -C /home/gerso/Development/ninjatronics-ai rev-parse HEAD

# Inventory
find . -path ./.git -prune -o -type f -print | sort
find . -path ./.git -prune -o -name '*.md' -type f -printf '%s\t%p\n' | sort -rn
find . -name 'package.json' -o -name '*.ts' -o -name '*.tsx' \
       -o -name 'pnpm-workspace.yaml' -o -name '*.prisma'      # → no results
ls -a .github/workflows/                                        # → empty
ls -la /home/gerso/Development/ninjatronics-ai/shared/standards/
wc -l /home/gerso/Development/ninjatronics-ai/shared/standards/*.md

# Content inspection
cat <file>; sed -n '<range>p' <file>; head -n N <file>
grep -n '^## ADR' docs/planning/DECISION_LOG.md
grep -n '^#\{1,3\} ' docs/architecture/*.md
grep -rn "MFA\|multi-factor" docs/
```

All commands are read-only. No `git` subcommand that writes was invoked.

### 13.2 Sources examined

**Zaifu (`/home/gerso/Development/zaifu`), read in full unless noted:**

| Path | Sections relied on |
|---|---|
| `README.md` | Orientation, document structure, agent coordination, current phase |
| `.gitignore` | Secret and personal-data exclusions (C-17) |
| `docs/planning/PHASE_0_GATE_REVIEW.md` | Gate criteria, Sentinel escalations, Archivist conflicts, transport evidence, **Gate Approval Addendum** |
| `docs/planning/DECISION_LOG.md` | ADR-001…ADR-025 (full); ADR-002, ADR-003 (untitled), ADR-005, ADR-007, ADR-010, ADR-011, ADR-012, ADR-019, ADR-021, **ADR-022…ADR-025** |
| `docs/planning/PRODUCT_REQUIREMENTS.md` | FR-01…FR-12, NFR-01…NFR-05, MVP exclusions, traceability |
| `docs/planning/USER_JOURNEYS.md` | J-01…J-05 and every edge-case table (**J-04 is forecast review, not import** — C-03) |
| `docs/planning/MVP_REFINED.md` | Refined boundary, five-step flow, Koban response shape |
| `docs/planning/MVP_PROOF_POINT.md` | Phase 1 implementation scope, MVP inclusion/exclusion lists |
| `docs/planning/ASSUMPTIONS.md` | Product, financial, security, architecture, Koban, user-control assumptions |
| `docs/planning/RISKS.md` | 14-row register, mitigation owners |
| `docs/planning/OPEN_QUESTIONS.md` | Data sources, architecture, AI/Koban, security, household, UX, financial definitions |
| `docs/planning/PHASE_0_GATE.md` | Exit criteria (partial — first 80 lines) |
| `docs/product/PRODUCT_CHARTER.md` | Governing sources, eight principles, MVP boundary, non-goals, constraints |
| `docs/product/TRUST_MODEL.md` | Four trust levels, recurring progression, confidence formula, thresholds, decay, import workflow |
| `docs/product/FINANCIAL_CONFIDENCE.md` | Confidence-not-certainty, **label-not-percentage** presentation rule |
| `docs/product/EXPLAINABILITY.md` | Six components (title says five — C-11) |
| `docs/product/SUCCESS_METRICS.md` | Principles, M-01…M-13, accuracy evidence requirements (partial — first 90 lines) |
| `docs/architecture/DOMAIN_MODEL.md` | All entities, money rules, recurrence, trust integration, ERD, audit, Phase 1.1 exclusions, glossary |
| `docs/architecture/FINANCIAL_ENGINE.md` | Engine overview, Ledger §1.1–1.4, Oracle §2.1–2.4, Strategist §3.1–3.4, worked interaction, determinism, Phase 1.1 |
| `docs/architecture/FINANCIAL_TEST_VECTORS.md` | Input format, confidence formula, TV-03, TV-16, TV-17, TV-22 in full; summary table and coverage matrix; section index for TV-01…TV-22 |
| `docs/security/SECURITY_ARCHITECTURE.md` | Objectives, assets, actors, trust boundaries, encryption, **authentication (line 93)**, authorization, audit, retention, residual risk |
| `docs/security/THREAT_MODEL.md` | Boundary requirements, actors, **TM-01…TM-15**, attack-surface requirements, residual-risk acceptance |
| `docs/security/DATA_CLASSIFICATION.md` | Four levels, handling matrix, inventory, Koban/provider rules, retention baseline, governance |
| `docs/orchestration/AGENT_ROSTER.md` | Core team, Phase 1+ team, assignment rules |
| `docs/orchestration/assignments/PH1-CLD-001.md` | This assignment |
| `shared/templates/ASSIGNMENT_TEMPLATE.md`, `HANDOFF_TEMPLATE.md` | Required handoff structure |

**Not read in full (not material to this plan):** `docs/product/VISION.md`,
`PHILOSOPHY.md`, `GLOSSARY.md`, `docs/planning/ARCHITECTURE_VISION.md`,
`USER_STORY_BEST_BUY.md`, `PHASE_0_{STATUS,COMPLETE,APPROVAL_MEMO,FINAL_HANDOFF,FINAL_SUMMARY}.md`,
`docs/orchestration/assignments/PH0-*.md`, `docs/orchestration/handoffs/PH0-ARC-001.md`.
Their content is historical or superseded by Tier 0–5 sources, and per the
assignment, Phase 0 ledger/handoff reconciliation is deferred.

**Ninjatronics (`/home/gerso/Development/ninjatronics-ai/shared/standards/`), read in full:**
`agent-routing.md`, `orchestration.md`, `collaboration-workflow.md`,
`security-review.md`. Also read: `specialist-transport.md` (listed, referenced
normatively by `agent-routing.md`'s dispatch section).

### 13.3 Graphify

`graphify-out/graph.json` is absent from Zaifu; confirmed by the full file
listing. Per `agent-routing.md` §"Availability rule", this is disclosed rather
than blocking, and the fallback to direct source inspection was used throughout.
Every conclusion above cites a file path, and the material ones cite a line or
section.

### 13.4 Statement on modification

**No file in `/home/gerso/Development/zaifu` or
`/home/gerso/Development/ninjatronics-ai` was created, modified, or deleted
during this assignment.** No dependency was installed. No branch, worktree,
commit, or pull request was created. No agent was dispatched. This handoff was
written to a session scratchpad outside both repositories.

---

## 14. Outstanding work

1. Orchestrator validation and synthesis of this plan.
2. Gerso approval at **G1**, together with **D-05** and **DO-06**, which Wave 1
   cannot proceed without.
3. **D-02** — recommended at plan approval, since it materially shapes WP-12,
   WP-13, and WP-15.
4. Resolution of escalation **E-04**: financial-correctness review ownership
   under the current roster.
5. Package sizing and scheduling, deliberately omitted (assumption A-08).
6. Formal assignment documents per `shared/templates/ASSIGNMENT_TEMPLATE.md` for
   each Wave 1 package, authored by the orchestrator.

---

*Prepared by Claude Code under assignment PH1-CLD-001, 23-08-2026.*
*Read-only analysis. Implementation-ready plan; no implementation performed.*
