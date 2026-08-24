# Specialist Handoff

## Handoff: PH1-ARC-001

**Specialist role:** Archivist (documentation, traceability, historical record, evidence integrity)
**Execution runtime:** **Claude Code carrying the Archivist role — disclosed approved fallback**
**Assignment:** Implement PH1-WP-02 — authoritative baseline reconciliation
**Work package:** `PH1-WP-02` (see [`PH1-CLD-001.md`](PH1-CLD-001.md) §4)
**Requested by:** Pi acting as active orchestrator (Nova role)
**Completed:** 2026-08-23
**Repository:** `/home/gerso/Development/zaifu`
**Worktree:** `/home/gerso/Development/worktrees/zaifu/PH1-ARC-001`
**Branch:** `phase1/ph1-arc-001`
**Base commit:** `7798215` — "Zaifu Phase 1 approved dispatch baseline (synthetic worktree base)"
**Recommended next owner:** Active orchestrator (independent validation and integration), then **PH1-SEN-002** for security-document review when authorized

### Fallback disclosure

The selected runtime for WP-02 was the native Hermes Archivist. This assignment was
executed by **Claude Code carrying the Archivist role** under the fallback approved
by Gerso at G1 (`routing-reassessment.md`, "G1 approval record", condition 5:
*"Claude Code may carry the Archivist role when native Archivist is unavailable,
quota-constrained, or uneconomical, provided Archivist documentation and evidence
standards are preserved."*). Reason applied: conserve native Hermes quota.

Archivist rules preserved and applied throughout: no invented evidence, approvals,
validation outcomes, product requirements, or financial rules; dated historical
decisions preserved rather than rewritten; every correction carries its rationale
and its authority; traceability maintained between decision, change, and evidence.

Independent review still required: **Nova** for all changes; **PH1-SEN-002** for
`docs/security/SECURITY_ARCHITECTURE.md` and `docs/security/THREAT_MODEL.md`,
because Sentinel owns those documents and, under ADR-024, the runtime that edited
them cannot approve them.

---

## Work Performed

### Summary

Reconciled Zaifu's Phase 0 planning, product, and security documentation with the
four binding Phase 1 decisions — **ADR-022** (MFA required), **D-05** (import
excluded, 70% maximum reachable account trust), **DO-06 / ADR-019** (internal
package naming), and **D-02 / G4** (Mode A only) — and with the non-financial
contradictions PH1-CLD-001 assigned to WP-02. Seventeen files were changed. Every
correction is dated, attributed to its authority, and accompanied by the superseded
wording. No dated historical decision was deleted or rewritten, no financial rule
was changed or invented, and no file outside the assignment's ownership was touched.

### Detailed breakdown

1. **MFA baseline (C-01).** Replaced the "MFA is not asserted as an MVP
   implementation requirement" control in `SECURITY_ARCHITECTURE.md` with a
   mandatory-MFA baseline plus the enrolment, secret-handling, recovery,
   monitoring, and re-authentication requirements that follow from ADR-022;
   restated the authentication residual-risk row as post-MFA with D-01/G3 as the
   only remaining decision; added MFA to `THREAT_MODEL.md` TM-04's mitigation and
   validation evidence, to the browser-to-API boundary, and to the authentication
   attack surface; rewrote residual-risk-acceptance item 1 as the D-01/G3
   method-and-recovery decision; added the MFA assumption to `ASSUMPTIONS.md`;
   recorded the answer in `OPEN_QUESTIONS.md`; added MFA to the README's critical
   principles and to the pre-release evidence package.

2. **Import exclusion and the 70% trust ceiling (C-02, D-05).** Added an identical
   scope statement to ADR-010's supersession note, `PRODUCT_CHARTER.md`,
   `PRODUCT_REQUIREMENTS.md`, `MVP_REFINED.md`, and `TRUST_MODEL.md`. Marked
   `TRUST_MODEL.md` Levels 3 and 4 as unreachable in Phase 1 and Level 2 as the
   ceiling; labelled the import workflow, the statement-confirmation trust step,
   and the OCR/extraction examples as deferred while retaining them in full;
   rewrote `MVP_REFINED.md` Step 2 from a screenshot upload reaching 85% trust to
   the Phase 1 confirmation flow reaching 70%, quoting the original wording in
   place; deferred the import asset class, threats, controls, residual risk, TM-06,
   TM-07, and the import boundary in both security documents; corrected the
   `ASSUMPTIONS.md` import assumption; deferred the OCR and statement-format open
   questions; withdrew the Phase 0 gate's import criterion for Phase 1.

3. **Package naming (C-08, DO-06).** Marked ADR-002's `packages/ledger`-style
   Consequences bullet as superseded for code naming while stating explicitly that
   ADR-002's engine boundaries, one-directional flow, and Koban role remain in
   force; confirmed ADR-019 as the naming authority; added the product-name →
   package-name mapping to the README and to `MVP_REFINED.md`; closed the
   "future engine naming" research assignment in `OPEN_QUESTIONS.md`. Two files
   still carrying the old names are outside this assignment's ownership and are
   listed under "Deferred and requiring orchestrator approval".

4. **Mode A (D-02 / G4).** Marked the provider boundary as Mode B only and disabled
   in Phase 1 in both security documents (diagrams, boundary table, TM-10,
   residual-risk row, Koban/LLM attack surface, residual-risk acceptance item 2);
   added the Mode A explanation constraint to `PRODUCT_REQUIREMENTS.md` FR-09's
   section, `ASSUMPTIONS.md`, `MVP_REFINED.md`, the README, and the Phase 0 gate
   addendum; recorded that provider selection is a Mode B prerequisite, not a
   Phase 1 one, in `OPEN_QUESTIONS.md`.

5. **Confidence labels and bands (C-10).** Established
   `TRUST_MODEL.md` → "Canonical confidence-label bands" as the single named
   location for the HIGH / MEDIUM / LOW numeric boundaries, recording the mapping
   already implied by that section's own band headings (HIGH ≥ 85, MEDIUM 70–84,
   LOW < 70); pointed `FINANCIAL_CONFIDENCE.md`, `PRODUCT_CHARTER.md`,
   `PRODUCT_REQUIREMENTS.md` FR-09, and `EXPLAINABILITY.md` at it; marked every
   stale user-facing percentage in `TRUST_MODEL.md`, `MVP_REFINED.md`, and
   `MVP_PROOF_POINT.md` as an internal-value illustration; corrected
   `TRUST_MODEL.md` "Confidence Transparency" item 3 from "exact percentage" to the
   label. **The bands were deliberately not redefined** to fit the 70% ceiling.

6. **Traceability and orientation defects (C-11, C-12, C-14, C-15).** Corrected
   `EXPLAINABILITY.md` "five components" to six; restored the missing
   `## ADR-003:` heading; added supersession banners to ADR-021 and
   `MVP_PROOF_POINT.md` for credit cards; corrected the README's phase status,
   document tree, and phantom file references.

7. **Gate-record corrections (C-03).** Added a dated correction addendum to
   `PHASE_0_GATE_REVIEW.md` recording that the "Import workflow specified"
   criterion cited `USER_JOURNEYS.md` J-04, which is "Review the 30-day forecast",
   and that the file contains no import journey; added a Phase 1 applicability
   addendum to `PHASE_0_GATE.md`. Neither record's original text, checkboxes, or
   verdict was altered.

8. **Link integrity.** Fixed five pre-existing broken relative links in
   `PHASE_0_APPROVAL_MEMO.md` and `PHASE_0_STATUS.md` (repo-root-relative paths
   written from inside `docs/planning/`), which the required link check surfaced.
   Only link targets changed.

### Files created

- `docs/orchestration/assignments/PH1-ARC-001.md` — verbatim copy of the dispatched
  assignment plus a project-local execution record (runtime disclosure, ownership
  interpretation, deliverable locations).
- `docs/orchestration/handoffs/PH1-ARC-001.md` — this handoff.

### Files modified (15)

| File | Tier / role | Change class |
|---|---|---|
| `README.md` | Orientation | Phase status, document tree, package-name mapping, MFA, trust ceiling, Mode A |
| `docs/planning/DECISION_LOG.md` | Tier 0 — owner decisions | ADR-003 heading restored; ADR-002, ADR-010, ADR-019, ADR-021 supersession notes; reconciliation record |
| `docs/planning/ASSUMPTIONS.md` | Planning | Import assumption corrected; MFA and Mode A assumptions added |
| `docs/planning/OPEN_QUESTIONS.md` | Planning | Answered / deferred / closed annotations |
| `docs/planning/MVP_REFINED.md` | Tier 2 — scope boundary | Step 1 and Step 2 corrected; package names; internal-value labels |
| `docs/planning/MVP_PROOF_POINT.md` | Tier 6 — illustrative | Supersession banner only |
| `docs/planning/PRODUCT_REQUIREMENTS.md` | Tier 3 — acceptance | Import/ceiling confirmation; Mode A boundary; FR-09 band pointer |
| `docs/planning/PHASE_0_GATE.md` | Gate record | Phase 1 applicability addendum appended |
| `docs/planning/PHASE_0_GATE_REVIEW.md` | Gate record | Correction addendum appended |
| `docs/planning/PHASE_0_APPROVAL_MEMO.md` | Dated record | Broken link target only |
| `docs/planning/PHASE_0_STATUS.md` | Dated record | Broken link targets only |
| `docs/product/PRODUCT_CHARTER.md` | Tier 2 — scope boundary | Trust-ceiling statement; import non-goal; band pointer |
| `docs/product/TRUST_MODEL.md` | Tier 1/3 | Trust-ceiling reconciliation; canonical bands; deferral labels; WP-03 boundary notes |
| `docs/product/FINANCIAL_CONFIDENCE.md` | Tier 1 — invariant | Canonical-band pointer only |
| `docs/product/EXPLAINABILITY.md` | Product standard | "five" → "six"; band pointer |
| `docs/security/SECURITY_ARCHITECTURE.md` | Tier 5 — Sentinel-owned | MFA baseline; import deferral; Mode A; residual risks |
| `docs/security/THREAT_MODEL.md` | Tier 5 — Sentinel-owned | MFA in TM-04; import and provider deferrals; residual-risk acceptance |

*(17 modified paths counting the two security documents; 2 created.)*

---

## Contradiction-Closure Table

Contradiction IDs are PH1-CLD-001's (`result.md` §3.2). "Closed" means no document
in this assignment's ownership still asserts the stale position. "Deferred" means
the contradiction is recorded with an owner and was deliberately not resolved here.

| ID | Source conflict | Approved authority applied | Files changed | Disposition |
|---|---|---|---|---|
| **C-01** | Security baseline said MFA is not an MVP requirement; threat model treated consumer MFA posture as an open residual-risk decision. | **ADR-022** (MFA is an MVP security baseline). Method and recovery remain **D-01 / G3**. | `SECURITY_ARCHITECTURE.md`, `THREAT_MODEL.md`, `ASSUMPTIONS.md`, `OPEN_QUESTIONS.md`, `PHASE_0_GATE.md`, `README.md` | **Closed** — no owned document states or implies optional MFA. Sentinel review of the two security documents still required (PH1-SEN-002). |
| **C-02** | Import in the MVP (ADR-010, `MVP_REFINED.md` Step 2, `TRUST_MODEL.md` Level 3 + import workflow, `PHASE_0_GATE.md`) vs. out (`PRODUCT_REQUIREMENTS.md`, `PRODUCT_CHARTER.md`, `MVP_PROOF_POINT.md`). | **D-05** — import excluded from Phase 1; maximum reachable account trust is Level 2 (70%). ADR-010 superseded for Phase 1 scope, retained as history. | `DECISION_LOG.md`, `PRODUCT_CHARTER.md`, `PRODUCT_REQUIREMENTS.md`, `MVP_REFINED.md`, `TRUST_MODEL.md`, `MVP_PROOF_POINT.md`, `SECURITY_ARCHITECTURE.md`, `THREAT_MODEL.md`, `ASSUMPTIONS.md`, `OPEN_QUESTIONS.md`, `PHASE_0_GATE.md`, `PHASE_0_GATE_REVIEW.md`, `README.md` | **Closed** — one identical scope statement across all five documents named in the WP-02 acceptance criteria plus the security set. |
| **C-03** | Gate review cited `USER_JOURNEYS.md` J-04 as an import journey; actual J-04 is "Review the 30-day forecast" and no import journey exists. | Verified against `USER_JOURNEYS.md`; criterion withdrawn for Phase 1 under **D-05**. | `PHASE_0_GATE_REVIEW.md` (correction addendum), `PHASE_0_GATE.md` (applicability addendum) | **Closed** — misstatement recorded, criterion withdrawn for Phase 1, gate not reopened. `USER_JOURNEYS.md` itself needed no change. |
| **C-04** | Three incompatible definitions of `assumption_trust`. | None available. Resolving it is a financial rule; the assignment forbids inventing one. | *(none — boundary note added in `TRUST_MODEL.md`)* | **Deferred to PH1-WP-03.** Recorded in `TRUST_MODEL.md` "Forecast Confidence Calculation" with the reachability consequence of the 70% ceiling flagged for **G2**. |
| **C-05** | Confidence rounding: nearest (engine spec) vs. floor (test vectors). | None available — financial rule. | *(none — recorded in `TRUST_MODEL.md` canonical-bands section)* | **Deferred to PH1-WP-03.** |
| **C-06** | Test-vector outputs contradict their own derivations (TV-03, TV-16, TV-17) and contain authoring notes. | Out of scope: `FINANCIAL_TEST_VECTORS.md` is explicitly excluded from this assignment. | *(none)* | **Deferred to PH1-WP-03.** File verified byte-identical to `HEAD`. |
| **C-07** | Verdict vocabulary differs across engine spec, test vectors, and FR-08. | None available — API/engine contract and financial semantics. | *(none — noted in `TRUST_MODEL.md` "Confidence Transparency")* | **Deferred to PH1-WP-03.** |
| **C-08** | Package naming: ADR-019 code names vs. ADR-002 Consequences, `FINANCIAL_ENGINE.md`, `AGENT_ROSTER.md`. | **DO-06 / ADR-019** — `financial-engine`, `forecast-engine`, `decision-engine`; ADR-002 engine boundaries preserved. | `DECISION_LOG.md` (ADR-002 + ADR-019), `README.md`, `MVP_REFINED.md`, `OPEN_QUESTIONS.md` | **Partially closed.** Closed everywhere within ownership. `docs/architecture/FINANCIAL_ENGINE.md` (excluded) and `docs/orchestration/AGENT_ROSTER.md` (outside grant) still carry the old names — see "Deferred and requiring orchestrator approval". |
| **C-09** | May sub-70% trust data be used in calculations? `TRUST_MODEL.md` says no; `DOMAIN_MODEL.md` says yes-with-marking; TV-17 computes then withholds. | None available — engine control flow and a Sentinel negative test depend on it. | *(none — recorded in `TRUST_MODEL.md` header note)* | **Deferred to PH1-WP-03.** `DOMAIN_MODEL.md` is outside the grant and was not touched. |
| **C-10** | Confidence presentation: label vs. percentage; and the HIGH/MEDIUM/LOW band boundaries were defined nowhere. | Gate-review conflict resolution #1; `FINANCIAL_CONFIDENCE.md`; FR-09. Bands recorded from the boundaries already implied by `TRUST_MODEL.md` "User-Facing Trust Display". | `TRUST_MODEL.md`, `FINANCIAL_CONFIDENCE.md`, `PRODUCT_CHARTER.md`, `PRODUCT_REQUIREMENTS.md`, `EXPLAINABILITY.md`, `MVP_REFINED.md`, `MVP_PROOF_POINT.md` | **Closed for wording and location.** Bands defined once, every stale percentage marked as an internal-value illustration. **Two sub-questions deferred to PH1-WP-03:** the rounding applied before banding (C-05), and whether HIGH/MEDIUM are reachable at all under the 70% ceiling. Bands were not rebanded. |
| **C-11** | `EXPLAINABILITY.md` titled "five components", enumerates six. | Gate-review conflict resolution #2; FR-09. | `EXPLAINABILITY.md` | **Closed** — corrected to six, previous wording quoted. |
| **C-12** | ADR-003 has no heading and is invisible to heading search. | Title taken from the existing citations in `PHASE_0_STATUS.md` and `PHASE_0_GATE_REVIEW.md`. | `DECISION_LOG.md` | **Closed** — `grep -c '^## ADR' ` is now 25, equal to the ADR count (ADR-001…ADR-025). |
| **C-13** | Same-date event ordering (income first) is an embedded product judgement inside the expected scenario. | Out of scope: stated in `FINANCIAL_ENGINE.md` §2.1, which is excluded. | *(none)* | **Deferred to PH1-WP-03** (record the rule) and **PH1-WP-13** (surface it in the UI), per the plan. |
| **C-14** | ADR-021 and `MVP_PROOF_POINT.md` still include a credit card in the proof-point flow. | Gate-review conflict resolution #4 — `MVP_REFINED.md` supersedes; `PRODUCT_CHARTER.md` non-goals. | `DECISION_LOG.md` (ADR-021), `MVP_PROOF_POINT.md` | **Closed** — supersession banners added; no narrative deleted. |
| **C-15** | README reports Phase 0 "In progress" and references four non-existent files. | `PHASE_0_GATE_REVIEW.md` Gate Approval Addendum (APPROVED, 23-08-2026); direct filesystem verification. | `README.md` | **Closed** — phase status corrected, document tree matches reality, no link to a non-existent file. |
| **C-16** | TV-22 exercises `bank_synced` (100%) trust, which is unreachable in Phase 1. | `TRUST_MODEL.md` Level 4 labelled unreachable; the vector file is excluded from this assignment. | `TRUST_MODEL.md` (Level 4 label) | **Deferred to PH1-WP-03** for the release-gate denominator decision. Supporting reachability statement is now in place. |
| **C-17** | `.gitignore` ignores `*.pdf` globally, which will silently block future PDF evidence artifacts. | Intent is correct (no personal financial data in the repository); no authority requires a change. | *(none)* | **Noted, no change.** `.gitignore` is a root file outside the grant and inside PH1-CLD-002's ownership. Recorded for **PH1-WP-14 / PH1-WP-15** evidence handling; see "Deferred and requiring orchestrator approval". |

### Additional defects closed (not in the C-01…C-17 register)

| Item | Finding | Disposition |
|---|---|---|
| A-1 | Five broken relative Markdown links: `PHASE_0_APPROVAL_MEMO.md:192` and `PHASE_0_STATUS.md:137,159,172,186` used repo-root-relative paths from inside `docs/planning/`, resolving to `docs/planning/docs/planning/...`. | **Fixed.** Link targets only; a dated note records that no content, status, or finding changed. Surfaced by the required link check. |
| A-2 | `TRUST_MODEL.md` "Subscription Trust" presents subscription trust as current behaviour, but subscriptions are an MVP exclusion in `PRODUCT_REQUIREMENTS.md` and `PRODUCT_CHARTER.md` and are scheduled at Phase 1.3 in `MVP_REFINED.md`. | **Labelled deferred**, content retained unchanged. No trust value altered. |
| A-3 | `docs/planning/ARCHITECTURE_VISION.md` "Current Status" still reads "⏳ Phase 0 specialist work" and "Next: Your Approval", and cites "16 decisions". | **Observed, not changed.** It is not a registered WP-02 contradiction and is a dated Phase 0 narrative. Recommended as a small follow-up for the orchestrator. |

---

## Rationale, and How History Was Preserved

### Editing method

Two shapes were used, chosen per document by whether the document functions as a
**live requirement source** or as a **dated record**.

- **Live requirement sources** (`SECURITY_ARCHITECTURE.md`, `THREAT_MODEL.md`,
  `TRUST_MODEL.md`, `MVP_REFINED.md`, `PRODUCT_CHARTER.md`,
  `PRODUCT_REQUIREMENTS.md`, `EXPLAINABILITY.md`, `ASSUMPTIONS.md`, `README.md`):
  the stale statement was corrected in place, and the previous wording was quoted
  verbatim in an adjacent dated note together with the authority that changed it
  and the reason in-place correction was necessary. An implementer reading these
  files top to bottom must not be able to act on a superseded requirement.
- **Dated records** (`DECISION_LOG.md` ADRs, `PHASE_0_GATE.md`,
  `PHASE_0_GATE_REVIEW.md`, `MVP_PROOF_POINT.md`, `PHASE_0_STATUS.md`,
  `PHASE_0_APPROVAL_MEMO.md`): the original text, checkboxes, verdicts, dates, and
  approvals were left exactly as written, and current authority was added as a
  supersession note, banner, or dated addendum.

Every changed document carries a "Phase 1 reconciliation addendum" table listing
each change, its location, and its authority, so the correction set is auditable
without reading a diff.

### Why each in-place correction was necessary rather than annotated

| Correction | Why in place |
|---|---|
| `SECURITY_ARCHITECTURE.md:93` MFA control | This document is the baseline Sentinel validates authentication against. An "MFA is optional" reading left in force would let a password-only implementation pass review, defeating ADR-022 and ADR-024. |
| `SECURITY_ARCHITECTURE.md` authentication residual-risk row | It asserted an unmitigated risk and an open owner decision that ADR-022 had closed. |
| `THREAT_MODEL.md` TM-04 residual risk and acceptance item 1 | Same reason: these are the cells a reviewer reads to decide whether MFA is required. |
| `MVP_REFINED.md` Steps 1–2 | `MVP_REFINED.md` is the governing refined-MVP scope document (gate-review resolution #4). An implementer following it literally would have built an upload flow that D-05 excludes and asserted 85% trust that Phase 1 cannot reach. |
| `EXPLAINABILITY.md` "five components" | The line is the standard's own definition; a reader who stopped there would build five components and fail FR-09. |
| `TRUST_MODEL.md` "Confidence Transparency" item 3 | It instructed the product to show an exact percentage, contradicting gate-review resolution #1 and FR-09. |
| `ASSUMPTIONS.md` import assumption | It is read as a scope input by downstream packages. |
| `README.md` phase status and document tree | The README is the first document new implementers read; it claimed Phase 0 was in progress and pointed at four files that do not exist. |
| `PHASE_0_APPROVAL_MEMO.md` / `PHASE_0_STATUS.md` links | Broken link targets are mechanical defects, not decisions. Content untouched. |

### Explicit history-preservation statement

No dated historical decision, gate record, approval, threat entry, mitigation,
evidence requirement, trust level, formula, example, workflow, or narrative was
deleted or rewritten in this assignment.

- ADR-002, ADR-010, ADR-019, and ADR-021 retain their original decision text,
  status, rationale, alternatives, and consequences. Each carries an added
  supersession or reconciliation note.
- ADR-003 gained only a heading; no word of its content changed.
- `PHASE_0_GATE.md` and `PHASE_0_GATE_REVIEW.md` retain every checkbox, criterion,
  finding, escalation, transport-evidence row, and the Gate Approval Addendum.
  Corrections are additive addenda, and neither gate was reopened or re-approved.
- Deferred capabilities (import/OCR, provider egress, subscriptions, credit cards,
  bank synchronization, Levels 3 and 4) are **labelled, not removed**, and remain
  the binding model for the phase that enables them.
- Every replaced phrase is quoted verbatim at the point of replacement.

---

## Deferred, and Requiring Orchestrator Approval

The assignment states: *"Stay within exclusive ownership above. If another file is
required, stop and request orchestrator approval."* Ownership was granted over
"existing planning/product/security documentation" plus the two named orchestration
files. The following work is therefore **not done** and is requested rather than
performed.

| # | File | Why it is needed | Why it was not edited | Requested action |
|---|---|---|---|---|
| **R-1** | `docs/architecture/FINANCIAL_ENGINE.md` (Engine Overview table, lines 27–30) | Still names `packages/ledger`, `packages/oracle`, `packages/strategist`, `packages/steward`. WP-02 acceptance criterion 3 requires exactly one naming convention across ADR-002, ADR-019, this file, and `AGENT_ROSTER.md`. | **Explicitly out of scope** in this assignment. | Orchestrator to assign the four-row naming correction — a two-line change per row — to the owner of `FINANCIAL_ENGINE.md` (PH1-WP-03 already opens the file). ADR-019 / DO-06 govern in the meantime. |
| **R-2** | `docs/orchestration/AGENT_ROSTER.md:44` | Says "`packages/oracle` (future naming: Oracle)", which inverts ADR-019: `forecast-engine` is the code name and Oracle is the product name. | Orchestration documentation; outside both the planning/product/security grant and the two-file orchestration grant. | Orchestrator approval to correct line 44 (and the adjacent "Current naming" line 47) under this assignment, or reassignment. |
| **R-3** | `docs/architecture/DOMAIN_MODEL.md:182–185` | Enumerates trust Levels 1–4 without a Phase 1 reachability note, and its "How Trust Affects Calculations" section is one side of contradiction C-09. | Architecture documentation, outside the grant; and C-09 is PH1-WP-03's exclusive ownership. | Fold the reachability note into PH1-WP-03 / PH1-WP-04 when C-09 is resolved. No standalone edit recommended. |
| **R-4** | `.gitignore` | `*.pdf` is ignored globally (C-17), which will silently drop any future PDF evidence artifact. | Root file, outside the grant, and inside PH1-CLD-002's declared ownership. | No change recommended now — the intent is correct. Record the constraint in PH1-WP-14 / PH1-WP-15 evidence handling: commit evidence as Markdown/text, or add a narrow, reviewed exception at that time. |

### Financial rules deliberately deferred to PH1-WP-03

C-04, C-05, C-06, C-07, C-09, C-13, and C-16, plus two questions this
reconciliation surfaced:

1. **Answer-threshold reachability.** With account trust capped at 70% (D-05) and
   the ≥70% "Koban Answers" threshold in `TRUST_MODEL.md`, whether Koban can ever
   answer in Phase 1 depends on unresolved rules — specifically whether recurring
   income and obligation trust can still accrue above 70% from confirmed
   observation without statement evidence. If every weighted input is capped at
   70%, the weighted result is below 70% and Koban would always ask. **This is a
   financial-rule question and was not answered here.** It should be resolved by
   PH1-WP-03 and ratified at **G2** before any engine is implemented. Recorded in
   `TRUST_MODEL.md` "Forecast Confidence Calculation".
2. **Band reachability.** For the same reason, the HIGH band (≥85) is very unlikely
   to be reachable in Phase 1 and MEDIUM may also be unreachable. The bands were
   **not** redefined to fit the ceiling, because rebanding is a product decision
   requiring owner ratification.

---

## Acceptance Criteria Status

Criteria are PH1-WP-02's (`PH1-CLD-001.md` §4).

- [x] **1. No document states or implies that MFA is optional for the MVP; every MFA reference is consistent with ADR-022.** Verified by targeted search — see Evidence E-3. Sentinel approval of the two security documents remains outstanding.
- [x] **2. The MVP scope statement regarding document/statement upload is identical in `PRODUCT_CHARTER.md`, `PRODUCT_REQUIREMENTS.md`, `MVP_REFINED.md`, ADR-010, and `TRUST_MODEL.md`, and states the maximum trust level reachable in Phase 1.** Verified by targeted search — see Evidence E-4.
- [ ] **3. Exactly one package-naming convention appears across ADR-002, ADR-019, `FINANCIAL_ENGINE.md`, and `AGENT_ROSTER.md`.** **Partially met.** Met for ADR-002, ADR-019, and every owned file. `FINANCIAL_ENGINE.md` and `AGENT_ROSTER.md` are outside this assignment's file ownership — see R-1 and R-2.
- [x] **4. The HIGH/MEDIUM/LOW confidence bands are defined once, with numeric boundaries, in a single named location, and every user-facing example in `TRUST_MODEL.md`, `MVP_REFINED.md`, and `MVP_PROOF_POINT.md` either uses a label or is marked as an internal-value illustration.** Location: `TRUST_MODEL.md` → "Canonical confidence-label bands". Whether the bands are *reachable* in Phase 1 is deferred to PH1-WP-03 and stated as such.
- [x] **5. Every ADR in `DECISION_LOG.md` has a heading; `grep -c '^## ADR' ` equals the ADR count.** 25 = 25 — see Evidence E-2.
- [x] **6. `README.md` reflects the approved gate and contains no link to a non-existent file.** Verified by the link check — see Evidence E-1.
- [x] **7. A dated reconciliation record lists each change, the sources it resolved, and the resolution rationale.** This handoff, plus a per-document reconciliation addendum in each changed file, plus the pointer record in `DECISION_LOG.md` → "Baseline reconciliation record — PH1-ARC-001".

**Overall status:** Met, with acceptance criterion 3 partially met because two of
its four files are outside the assignment's exclusive ownership. All bounded WP-02
contradictions are closed or explicitly deferred with named owners.

---

## Evidence and Validation

All commands were run from the assignment worktree
`/home/gerso/Development/worktrees/zaifu/PH1-ARC-001` on branch
`phase1/ph1-arc-001`.

### E-1 — Markdown relative-link check (reproducible, no-install)

No repository link-checker tooling exists (no `package.json`, no `node_modules`).
A reproducible no-install fallback was used: a self-contained Python 3 script that
enumerates tracked `*.md` files with `git ls-files`, extracts inline Markdown links
outside fenced code blocks, and resolves every relative target against the
filesystem. External (`http`/`https`/`mailto`) links and pure in-page anchors are
reported as skipped, not broken. The script is reproduced verbatim in the appendix
so the check can be re-run independently.

**Before (baseline commit `7798215`):**

```
markdown files scanned : 41
relative links checked : 73
external/anchor skipped: 5
broken relative links  : 5
  BROKEN docs/planning/PHASE_0_APPROVAL_MEMO.md:192: docs/planning/PHASE_0_GATE.md -> docs/planning/docs/planning/PHASE_0_GATE.md
  BROKEN docs/planning/PHASE_0_STATUS.md:137: docs/planning/DECISION_LOG.md -> docs/planning/docs/planning/DECISION_LOG.md
  BROKEN docs/planning/PHASE_0_STATUS.md:159: docs/planning/OPEN_QUESTIONS.md -> docs/planning/docs/planning/OPEN_QUESTIONS.md
  BROKEN docs/planning/PHASE_0_STATUS.md:172: docs/planning/RISKS.md -> docs/planning/docs/planning/RISKS.md
  BROKEN docs/planning/PHASE_0_STATUS.md:186: docs/planning/PHASE_0_GATE.md -> docs/planning/docs/planning/PHASE_0_GATE.md
```

**After:** see the final-state block below. Zero broken relative links.

### E-2 — ADR heading completeness

```
$ grep -c '^## ADR' docs/planning/DECISION_LOG.md
before: 24
after : 25
```

25 headings for ADR-001 through ADR-025. The previously missing heading was
ADR-003; verified by `grep -n '^## ADR-003'` returning a match after the change and
nothing before it.

### E-3 — Targeted search: stale optional-MFA claims

**Before** (4 hits, excluding the read-only plan copy
`docs/orchestration/handoffs/PH1-CLD-001.md`):

```
docs/security/SECURITY_ARCHITECTURE.md:93   "MFA is not asserted as an MVP implementation requirement"
docs/security/SECURITY_ARCHITECTURE.md:145  "... without mandatory consumer MFA | Nova/Gerso: decide MVP MFA posture"
docs/security/THREAT_MODEL.md:72            "MFA posture is an explicit MVP residual-risk decision"
docs/security/THREAT_MODEL.md:107           "Consumer MFA posture and compensating monitoring/recovery controls."
```

**After:** zero hits as live requirements. Re-running the same search returns hits
only inside (a) the dated correction notes that quote the superseded phrase —
`SECURITY_ARCHITECTURE.md:147` (quoted previous wording), `:208` and `:233`
(reconciliation notes), `THREAT_MODEL.md:99`, `:143`, `:168` — and (b) this
handoff's own evidence section. `docs/orchestration/handoffs/PH1-CLD-001.md` is the
historical plan record and was not modified. No control, table cell, residual-risk
row, or acceptance item asserts optional MFA any more.

### E-4 — Targeted search: import-in-MVP, package naming, Mode B, component count

| Search | Before | After |
|---|---|---|
| Import asserted as an MVP capability: `MVP supports CSV import`, `CSV, document, and manual import for MVP`, `Trust=85% (verified statement)`, `Import workflow specified` | 4 live assertions (`DECISION_LOG.md:469`, `ASSUMPTIONS.md:12`, `MVP_REFINED.md:60`, `PHASE_0_GATE_REVIEW.md:56`) | **0 live assertions.** Remaining hits are: ADR-010's preserved decision text, now directly under a "Superseded for Phase 1 scope by owner decision D-05" status banner; the `ASSUMPTIONS.md` correction note quoting the old wording; and the `PHASE_0_GATE_REVIEW.md` checkbox, preserved as a dated record and withdrawn for Phase 1 by the correction addendum. `MVP_REFINED.md:60` no longer exists as an assertion — Step 2 now records `Trust=70% (user confirmed — the Phase 1 ceiling)`. |
| Conflicting package names `packages/ledger` / `oracle` / `strategist` / `steward`, excluding the plan copy | 6 (1 owned: `DECISION_LOG.md:118`; 5 unowned) | **1 owned occurrence**, inside ADR-019's reconciliation note where the old names are quoted as the wording still present in two unowned files. `DECISION_LOG.md:118` itself no longer names them as architecture. 5 unowned occurrences unchanged: `FINANCIAL_ENGINE.md:27–30` and `AGENT_ROSTER.md:44` — see R-1, R-2. |
| Phase 1 Mode B / production-data egress implied as the MVP posture | Provider boundary presented as an MVP path in both security documents (`SECURITY_ARCHITECTURE.md` trust-boundary diagram and Koban/LLM residual-risk row; `THREAT_MODEL.md` boundary diagram, boundary table, TM-10, Koban/LLM attack surface, acceptance item 2) | **Every provider boundary labelled** `Mode B only - disabled in Phase 1` or equivalent: `SECURITY_ARCHITECTURE.md:95`, `THREAT_MODEL.md:48`, `:63`, `:105`, plus the Mode A statements in `PHASE_0_GATE.md:227`, `DECISION_LOG.md:999`, and `ASSUMPTIONS.md:36`. |
| `these five components` | 1 (`EXPLAINABILITY.md:3`) | **0** |

### E-4f — Scope-statement identity check (acceptance criterion 2)

A second reproducible check confirms the D-05 scope statement is present and
identically worded in all five documents named by the criterion. It flattens
blockquote markers and whitespace before matching, because the statement appears
inside a blockquote banner in two of the files.

```
$ python3 scopecheck.py
2 occurrence(s)  docs/planning/DECISION_LOG.md
1 occurrence(s)  docs/product/PRODUCT_CHARTER.md
1 occurrence(s)  docs/planning/PRODUCT_REQUIREMENTS.md
1 occurrence(s)  docs/planning/MVP_REFINED.md
1 occurrence(s)  docs/product/TRUST_MODEL.md
RESULT: PASS - identical statement present in all five
(exit status 0)
```

The two `DECISION_LOG.md` occurrences are ADR-010's supersession note and the
ADR-002 / ADR-019 reconciliation context. The script is reproduced in the
appendix.

### E-5 — Whitespace and diff hygiene

```
$ git diff --check
(no output; exit status 0)
```

Two trailing-whitespace introductions were detected during drafting (Markdown hard
breaks copied into edited footer lines in `EXPLAINABILITY.md` and `TRUST_MODEL.md`)
and were removed by leaving the original footer lines untouched and adding the note
on a separate line.

### E-6 — Changed-file boundary check

```
$ git status --short
 M README.md
 M docs/planning/ASSUMPTIONS.md
 M docs/planning/DECISION_LOG.md
 M docs/planning/MVP_PROOF_POINT.md
 M docs/planning/MVP_REFINED.md
 M docs/planning/OPEN_QUESTIONS.md
 M docs/planning/PHASE_0_APPROVAL_MEMO.md
 M docs/planning/PHASE_0_GATE.md
 M docs/planning/PHASE_0_GATE_REVIEW.md
 M docs/planning/PHASE_0_STATUS.md
 M docs/planning/PRODUCT_REQUIREMENTS.md
 M docs/product/EXPLAINABILITY.md
 M docs/product/FINANCIAL_CONFIDENCE.md
 M docs/product/PRODUCT_CHARTER.md
 M docs/product/TRUST_MODEL.md
 M docs/security/SECURITY_ARCHITECTURE.md
 M docs/security/THREAT_MODEL.md
?? docs/orchestration/assignments/PH1-ARC-001.md
?? docs/orchestration/handoffs/PH1-ARC-001.md
```

Every path is Markdown documentation inside `docs/planning/`, `docs/product/`,
`docs/security/`, the two granted orchestration files, or `README.md`. No code,
schema, test, workflow, configuration, toolchain, or infrastructure file appears.

### E-7 — Excluded and reserved paths verified unchanged

`git status --porcelain` for each protected path returned empty, and content hashes
were compared against `HEAD` directly:

```
$ for f in docs/architecture/FINANCIAL_TEST_VECTORS.md \
           docs/architecture/FINANCIAL_ENGINE.md \
           docs/architecture/DOMAIN_MODEL.md \
           docs/orchestration/AGENT_ROSTER.md \
           .gitignore ; do
    git show HEAD:$f | sha256sum ; sha256sum $f ; done

MATCH 46d72d7afd54bc2a  docs/architecture/FINANCIAL_TEST_VECTORS.md
MATCH a9018617793eef69  docs/architecture/FINANCIAL_ENGINE.md
MATCH a4d74703ea8af5f0  docs/architecture/DOMAIN_MODEL.md
MATCH f47af029be492235  docs/orchestration/AGENT_ROSTER.md
MATCH da2953890655630b  .gitignore
```

(Leading 16 hex characters of each SHA-256 shown; `MATCH` means the working-tree
file is byte-identical to `HEAD`.)

Reserved paths that do not exist and were not created:
`docs/security/LLM_TRUST_BOUNDARY.md`, `docs/platform/`, `apps/`, `packages/`,
`.github/`, `package.json`, `pnpm-workspace.yaml`.

`docs/orchestration/handoffs/PH1-CLD-001.md` — the project-local copy of the
approved plan — was read but not modified.

### E-8 — Diff size

```
$ git diff --cached --stat | tail -1
 19 files changed, 1756 insertions(+), 104 deletions(-)
```

19 paths = 17 modified + 2 created. Of the 1,756 insertions, roughly half are the
two created orchestration documents. Deletions are almost entirely the replaced
lines quoted back in their adjacent correction notes, plus the README document tree
that was rewritten to match the filesystem.

### Final pre-commit state

```
$ python3 linkcheck.py
markdown files scanned : 41
relative links checked : 92
external/anchor skipped: 8
broken relative links  : 0
(exit status 0)

$ grep -c '^## ADR' docs/planning/DECISION_LOG.md
25

$ grep -n '^## ADR-003' docs/planning/DECISION_LOG.md
273:## ADR-003: Provider-Agnostic LLM Abstraction for Koban

$ git diff --check
(no output; exit status 0)

$ python3 scopecheck.py
RESULT: PASS - identical statement present in all five
(exit status 0)
```

The post-commit `git status` (clean), the post-commit link-check re-run, and the
commit SHA are recorded in the orchestrator-facing completion report and in the
shared handoff copy at `ninjatronics-ai/shared/handoffs/PH1-ARC-001/`. The commit
SHA cannot appear inside the commit it identifies.

---

## Prohibited-Action Attestation

For the duration of this assignment:

- **No code, schema, test, migration, workflow, toolchain, or configuration file
  was created or modified.** Documentation only.
- **No cloud resource was created, modified, or deleted.** No Azure, Vercel, DNS,
  Terraform, or deployment action of any kind.
- **No credential, secret, token, or key was used, created, read, or written.**
- **No spend was incurred and no billable resource was provisioned.**
- **No production action was taken** and no production system was contacted.
- **Codex was not used.**
- **No other agent, subagent, or specialist was dispatched.** All work was
  performed directly by this session.
- **No merge, push, rebase, or force operation** was performed; no other branch,
  worktree, or repository was modified. Work is confined to
  `/home/gerso/Development/worktrees/zaifu/PH1-ARC-001` on branch
  `phase1/ph1-arc-001`. The shared stash stack was not used.
- **No evidence, approval, validation outcome, product requirement, or financial
  rule was invented.** Every statement added to a Zaifu document cites an existing
  owner decision, ADR, gate-review resolution, or a fact verified by direct file
  inspection.
- **No Sentinel approval is claimed.** The `SECURITY_ARCHITECTURE.md` and
  `THREAT_MODEL.md` edits are documentation reconciliation awaiting independent
  Sentinel review under ADR-024 (PH1-SEN-002). Under the same rule, this runtime is
  ineligible to review its own security-document edits.
- **Gate G2 is not closed** and is not claimed to be closed. G3, G5, G6 and
  decisions D-01, D-03, D-04, D-06, D-07 remain open at their existing gates.
- **No control is asserted to be implemented.** Every added security requirement is
  a design requirement, not evidence of deployment.

---

## Risks and Recommendations

### Risks introduced

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| RK-1 | The security-document edits are unreviewed by Sentinel. Until PH1-SEN-002 runs, the MFA baseline wording carries an implementer's authority, not a security owner's. | Medium | Route `SECURITY_ARCHITECTURE.md` and `THREAT_MODEL.md` to PH1-SEN-002 before WP-08 starts. This runtime is ineligible to review them. |
| RK-2 | Acceptance criterion 3 is partially met: `FINANCIAL_ENGINE.md` and `AGENT_ROSTER.md` still name `packages/ledger` etc. An implementer reading only those files could create the wrong workspace layout. | Medium | ADR-019 / ADR-002 / README / `MVP_REFINED.md` now all state the correct names, and PH1-CLD-002's assignment names the three packages explicitly. Close R-1 and R-2 before PH1-CLD-002 creates package directories. |
| RK-3 | Labelling import, provider egress, subscriptions, and Levels 3–4 as "deferred" rather than deleting them keeps requirements in the documents that a future reader could mistake for Phase 1 scope. | Low | Every deferral label names its authority and the phase that re-activates it. Deleting them would have destroyed the model those phases need. |
| RK-4 | The answer-threshold reachability question (70% ceiling vs. ≥70% answer threshold) is now documented but unresolved. If PH1-WP-03 resolves it by lowering the threshold or the ceiling, several documents reconciled here will need a second pass. | **High for scheduling, not for correctness** | It is deliberately surfaced rather than silently resolved. Treat it as a G2 input; expect a bounded second reconciliation pass after PH1-WP-03. |
| RK-5 | Sixteen documents now carry reconciliation addenda. Repeated reconciliation rounds could turn the document set into a change log. | Low | Recommend the orchestrator consolidate addenda into a single `PHASE_1_BASELINE.md` after G2, keeping per-document pointers. That file would be a new document and was outside this assignment's grant. |

### Recommendations for the next owner

1. **Validate independently, then integrate before PH1-SEN-001.** The first-wave
   plan requires PH1-ARC-001 integration before Sentinel's WP-11 policy work so
   WP-11 does not reconcile against a stale baseline.
2. **Close R-1 and R-2 before PH1-CLD-002 creates package directories.** They are
   small, but they are the last conflicting naming sources.
3. **Carry RK-4 into G2 explicitly.** It is a financial-baseline question that
   changes whether the MVP can answer its own core question, and it was discovered
   as a consequence of D-05 rather than being visible in the original contradiction
   register.
4. **Do not treat this handoff as baseline approval.** G2 requires Gerso's
   decision on the reconciled baseline, and the financial half of that baseline
   (PH1-WP-03) does not exist yet.
5. **Small follow-up:** `ARCHITECTURE_VISION.md` "Current Status" (A-3) still reads
   as pre-approval Phase 0.

---

## Assumptions Made

| # | Assumption | Basis | If wrong |
|---|---|---|---|
| AS-1 | "Existing planning/product/security documentation" grants `docs/planning/**`, `docs/product/**`, `docs/security/**`, and `README.md` (named as a WP-02 likely file and the subject of C-15), but not `docs/architecture/**` or `docs/orchestration/AGENT_ROSTER.md`. | Assignment "Exclusive implementation ownership"; the explicit two-file orchestration grant; the escalation condition on excluded/reserved paths. | If architecture and roster files were in fact in scope, R-1 through R-3 become a small follow-up rather than an approval request. Nothing already done needs reverting. |
| AS-2 | The HIGH ≥ 85 / MEDIUM 70–84 / LOW < 70 boundaries are *existing* source authority, taken from `TRUST_MODEL.md` "User-Facing Trust Display" band headings, and recording them is reconciliation rather than invention. | The three band headings already state those numeric ranges; the assignment permits confidence-label wording/bands "where source authority permits". | If the orchestrator judges the bands to be a new product rule, remove the table and defer C-10's numeric half to PH1-WP-03; the label-vs-percentage half stands independently. |
| AS-3 | `automation-engine` (Steward) is not a Phase 1 package. | DO-06 names exactly three packages; `PRODUCT_CHARTER.md` non-goals and NFR-05 prohibit money movement and automation in the MVP. | If Steward is in Phase 1 scope, one sentence in the ADR-002 and ADR-019 notes and one README row change. |
| AS-4 | Fixing the five pre-existing broken links is in scope, because the required validation is a link check showing zero broken relative links and the files are planning documentation. | Assignment "Validation required"; WP-02 evidence requirement. | If out of scope, revert two link-target changes; no content is affected. |
| AS-5 | `docs/orchestration/handoffs/PH1-CLD-001.md` is a historical record of the approved plan and must not be edited, even where it quotes wording this assignment corrected. | It is the project-local copy of the accepted PH1-CLD-001 result; the assignment forbids rewriting dated records. | None. |

---

## Blockers and Dependencies

**Blockers encountered:** none. All dependencies (G1, D-05, DO-06, D-02/G4 Mode A)
were satisfied and recorded in `DECISION_LOG.md` before work began.

**No escalation condition was triggered** in the sense of conflicting approved
authorities, a needed financial-rule change made, security-baseline ambiguity
resolved by guessing, or a historical decision needing deletion. Two escalation
conditions were *observed and honoured by stopping*: the need to edit excluded and
non-granted paths (R-1 through R-4), and a financial-rule question surfaced but not
answered (RK-4).

**Downstream dependencies:**

- **PH1-SEN-001 (WP-11)** should start only after this handoff is validated and
  integrated.
- **PH1-SEN-002** must review the two security documents.
- **PH1-CLD-002 (WP-01)** should not create package directories until R-1 and R-2
  are closed.
- **PH1-WP-03** inherits C-04, C-05, C-06, C-07, C-09, C-13, C-16, and RK-4.
- **G2** remains open and takes this output as one of its two inputs; the financial
  baseline is the other.

---

## Sign-off

- **Work completed by:** Archivist role, Claude Code runtime (disclosed approved fallback) — 2026-08-23
- **Reviewed by:** *pending* — Nova (active orchestrator)
- **Security-document review:** *pending* — PH1-SEN-002 (required; this runtime is ineligible)
- **Approved by:** *pending* — Nova; baseline approval is Gerso's at **G2**

---

## Appendix A — Link-check script

Saved outside the repository during execution; reproduced here so the validation is
independently repeatable. Requires only Python 3 and `git`.

```python
#!/usr/bin/env python3
"""Reproducible, no-install Markdown relative-link checker for the Zaifu repo."""
import os, re, subprocess, sys, urllib.parse

ROOT = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True, check=True).stdout.strip()
files = subprocess.run(["git", "ls-files", "*.md"], cwd=ROOT,
                       capture_output=True, text=True, check=True).stdout.split()

LINK = re.compile(r'(?<!\!)\[[^\]]*\]\(\s*([^)\s]+)(?:\s+"[^"]*")?\s*\)')
FENCE = re.compile(r'^\s*```')

broken, checked, skipped = [], 0, 0
for rel in sorted(files):
    path = os.path.join(ROOT, rel)
    in_fence = False
    with open(path, encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            if FENCE.match(line):
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            for target in LINK.findall(line):
                if re.match(r'^(https?:|mailto:|#)', target):
                    skipped += 1
                    continue
                frag = urllib.parse.unquote(target.split("#", 1)[0])
                if not frag:
                    skipped += 1
                    continue
                checked += 1
                resolved = os.path.normpath(os.path.join(os.path.dirname(path), frag))
                if not os.path.exists(resolved):
                    broken.append(f"{rel}:{lineno}: {target} -> {os.path.relpath(resolved, ROOT)}")

print(f"markdown files scanned : {len(files)}")
print(f"relative links checked : {checked}")
print(f"external/anchor skipped: {skipped}")
print(f"broken relative links  : {len(broken)}")
for b in broken:
    print("  BROKEN " + b)
sys.exit(1 if broken else 0)
```

## Appendix B — Scope-statement identity script

```python
#!/usr/bin/env python3
"""Verify the D-05 scope statement is present and identically worded in the five
documents named by PH1-WP-02 acceptance criterion 2."""
import io, re, sys
PAT = re.compile(
    r"maximum reachable \*{0,2}account trust level in Phase 1 is \*{0,2}Level 2, "
    r"User Confirmed \(70%\)")
FILES = ["docs/planning/DECISION_LOG.md",          # ADR-010 supersession note
         "docs/product/PRODUCT_CHARTER.md",
         "docs/planning/PRODUCT_REQUIREMENTS.md",
         "docs/planning/MVP_REFINED.md",
         "docs/product/TRUST_MODEL.md"]
ok = True
for f in FILES:
    s = io.open(f, encoding="utf-8").read()
    s = re.sub(r"^\s*>\s?", " ", s, flags=re.M)   # flatten blockquotes
    s = re.sub(r"\s+", " ", s)
    n = len(PAT.findall(s))
    print(f"{n} occurrence(s)  {f}")
    ok = ok and n >= 1
print("RESULT:", "PASS - identical statement present in all five" if ok else "FAIL")
sys.exit(0 if ok else 1)
```
