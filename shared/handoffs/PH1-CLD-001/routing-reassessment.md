# PH1-CLD-001 Routing Reassessment

**Date:** 2026-08-23
**Status:** Approved by Gerso at G1 on 2026-08-23; implementation not dispatched
**Basis:** Existing `result.md`, Pi `validation.md`, `APPEND_SYSTEM.md`, ADR-022–ADR-025, and current specialist/runtime availability.

This artifact supplements but does not replace the original plan or validation. No implementation or review agent was dispatched.

## Rules applied

- Specialist role/domain ownership and execution runtime are separate.
- Native specialist runtimes are preferred when available and economical.
- A disclosed, approved fallback runtime may carry a specialist role and its domain rules.
- A runtime that implements a control cannot approve that control under a reviewer role. A new session of that runtime is not independent.
- Human gates G1–G6 and D-01–D-07 remain unchanged.
- Hermes quota exhaustion is runtime unavailability, not role unavailability.
- Handoffs should cite the validated plan and include only package-specific context and evidence.

## Revised routing matrix

| Work Package | Specialist Role | Preferred Runtime | Fallback Runtime | Independent Reviewer | Hermes Required? | Human Approval Required? | Notes |
|---|---|---|---|---|---|---|---|
| WP-01 | Forge; Sentinel for repository controls | Claude Code | Codex after naming/layout design is approved | Nova; Sentinel for scanning/protection | No | G2 before directories | Design may start, but directory creation waits for package naming. |
| WP-02 | Archivist; Sentinel for security-document ownership | Hermes Archivist | Claude Code carrying Archivist rules | Nova; Sentinel for security document edits | No | D-05 and G2 | Native Archivist is preferred; Claude is suitable for long-context fallback. |
| WP-03 | Ledger | Ledger-native runtime, currently unavailable | Claude Code carrying Ledger rules for reconciliation | Codex carrying Ledger review rules, independent of Claude; Nova; Gerso ratifies baseline | No, if fallback is approved | G2 | No engine work until canonical fixtures pass automated checks and the named independent Ledger fallback approves. |
| WP-04 | Forge with Ledger entity semantics | Claude Code | Codex only after schema design is approved | Ledger fallback on a runtime not implementing WP-04; Sentinel for security controls | No | G2 already governs baseline | Apply Pi correction: omit household functionality; any inert future column needs separate justification. |
| WP-05 | Ledger | Codex | Claude Code | Ledger-role reviewer on Claude Code; Nova | No | No additional human gate | Codex implementer cannot perform Ledger approval. Fixture conformance remains mandatory. |
| WP-06 | Forecast/Oracle under Ledger correctness | Codex | Claude Code | Ledger-role reviewer on Claude Code; Nova | No | No additional human gate | Same implementation/reviewer separation as WP-05. |
| WP-07 | Ledger; Archivist for product wording | Codex | Claude Code | Ledger-role reviewer on Claude Code; Archivist for wording; Nova | No | No additional human gate | Codex implementer cannot approve financial correctness. |
| WP-08 | Sentinel control ownership; Forge implementation | Claude Code | Codex after approved auth design | Sentinel on Hermes; if unavailable, Codex may review only when Codex did not implement any reviewed control | No, if an independent fallback remains unused by implementation | G3 | Never assign Sentinel approval to the implementing runtime. |
| WP-09 | Forge; Sentinel authorization; Ledger output integrity | Claude Code primary | Codex for bounded handlers or full implementation after design | Sentinel independent of all security-control implementers; Ledger reviewer independent of engine/API implementation | Conditional | G3 remains prerequisite | If both Claude and Codex implement reviewed security controls, Hermes Sentinel becomes required unless another approved independent runtime exists. |
| WP-10 | Sentinel control ownership; Forge implementation; Archivist evidence | Codex | Claude Code | Hermes Sentinel preferred; Claude Sentinel fallback only if Claude did not implement reviewed controls; Archivist independent evidence review | No, with preserved separation | D-06 before close/release | Codex implementer cannot provide Sentinel approval. |
| WP-11 | Sentinel trust-boundary policy; Koban constraints | Hermes Sentinel | Claude Code carrying Sentinel rules | Nova; independent Sentinel validation at WP-15; Ledger checks numeric fidelity | No | G4 / D-02 | WP-02 may run concurrently only for discovery; WP-11 cannot finalize before WP-02 closes. |
| WP-12 | Koban with Sentinel security ownership | Claude Code | Codex after policy/design approval | Sentinel on a runtime not implementing WP-12; Ledger reviewer for value fidelity | No, if reviewer runtime is reserved | G4; second approval before identifiable production egress | Mode A remains default; no provider-data approval is inferred. |
| WP-13 | Interface; Archivist requirements; Sentinel client security | Claude Code | Codex after UX architecture approval | Archivist and Sentinel, each independent of implementation for their approval scope | No | D-03 before completion | Keep implementation on one runtime if Codex must be reserved as Sentinel fallback. |
| WP-14 | Shinobi; Sentinel security | Hermes Shinobi | Claude Code for broad design/implementation; Codex for bounded modules | Sentinel independent of all infrastructure implementers; Nova | No for design/implementation; conditional for review | G5 before resources, spend, or deployment | Shinobi profile exists but is not in the validated dispatcher allow-list. That transport gap must not block fallback execution. If Claude and Codex both implement controls, reserve Hermes Sentinel for review. |
| WP-15 | Sentinel independent pre-release validation | Hermes Sentinel | Codex carrying Sentinel rules only if Codex implemented none of the security controls under review; otherwise another approved untouched runtime | Nova validates identity/evidence; Gerso accepts or rejects release risk | Conditional, not intrinsic | G6 / D-07 | Native Hermes is strongly preferred. With the current mixed Claude/Codex implementation plan, Hermes is the only already-available clearly independent reviewer. A fallback requires implementation routing that preserves it. |
| WP-16 | Nova coordination; Archivist evidence; Sentinel privacy; Ledger accuracy | Codex for instrumentation; human study | Claude Code for instrumentation | Sentinel for privacy, Ledger for accuracy, Archivist for evidence; all independent of their reviewed work | No | G6 | The study remains human work; no runtime may fabricate usability evidence. |

## Runtime conclusions

### Can proceed without Hermes

All packages can proceed without Hermes in principle if Gerso approves the named fallbacks and runtime separation is reserved in advance. WP-01, WP-03–WP-07, and non-security implementation portions are straightforward. WP-02, WP-11, WP-14, and WP-15 have native specialist runtimes, but native-runtime unavailability alone is not a role blocker.

### Genuinely Hermes-dependent

No package is intrinsically Hermes-only under the new rules. WP-15 becomes operationally Hermes-dependent if both Claude Code and Codex implement security controls, because neither runtime would then be independent for final Sentinel approval. The safe choices are:

1. Prefer native Hermes Sentinel for WP-15; or
2. Reserve Codex from all security-control implementation and authorize it as the Sentinel-role fallback; or
3. Approve another independent runtime that has not implemented reviewed controls.

A new Claude or Codex session does not restore independence after that runtime implemented a reviewed control.

### Claude Code use

Claude Code remains preferred for broad design and multi-file work: WP-01, WP-04, WP-08, WP-09, WP-12, WP-13, and broad WP-14 work. It is the recommended fallback for Archivist WP-02, Sentinel WP-11, and Ledger WP-03 when carrying those profiles/domain rules explicitly.

### Codex use

Codex remains preferred for bounded, fixture-driven implementation: WP-05–WP-07, WP-10, and WP-16 instrumentation. It may handle bounded portions of WP-01, WP-04, WP-08, WP-09, WP-12–WP-14 after design approval. It may serve as an independent Sentinel fallback only for controls it did not implement, and as a Ledger reviewer only when Claude Code performed the financial work.

## Sentinel independence

- Sentinel remains the required role for ADR-024 validation; Hermes is the preferred runtime, not the role itself.
- Every security assignment records the implementing runtime(s).
- A runtime is ineligible to approve any control it implemented, even in a new session or under a Sentinel prompt.
- The recommended default is native Hermes Sentinel for package security reviews and WP-15.
- If Hermes is unavailable, reserve one approved runtime from security implementation and assign it the Sentinel profile/domain rules, evidence requirements, and final verdict duty.
- Missing or failed evidence still blocks release unless Gerso explicitly accepts the residual risk.

## Ledger and financial correctness

The absent Ledger runtime does not by itself make the Ledger role unavailable. It does, however, require a formally named fallback and separation of authorship from approval.

Recommended pattern:

- WP-03 financial baseline: Claude Code performs Ledger-role reconciliation; Codex independently reviews every rule and fixture under Ledger rules; Gerso ratifies the changed baseline at G2.
- WP-05–WP-07: Codex implements; Claude Code performs independent Ledger-role review.
- WP-04/WP-09/WP-12/WP-16: the Ledger reviewer must be a runtime that did not implement the financial semantics or evidence being approved.
- Automated fixture-schema validation, 100% in-scope vector conformance, deterministic tests, integer-cent precision, provenance, and release accuracy gates remain mandatory.
- Nova coordinates and validates evidence but does not substitute for independent Ledger approval.

Gerso authorized Claude Code and Codex to carry the Ledger role with this authorship/reviewer separation on 2026-08-23. The financial correctness gate is unchanged.

## Recommended first wave

Keep the same package set but change routing and sequencing:

1. WP-02: native Archivist preferred; Claude fallback. Start first after D-05. Sentinel independently approves security-document changes.
2. WP-11: native Sentinel preferred; Claude fallback. Discovery may start, but final policy waits for WP-02 and G4/D-02.
3. WP-01: Claude Code. Design may start; no package directories before G2 naming resolution.
4. WP-14: native Shinobi preferred; Claude fallback. Design only before G5; no resources or spend.

Do not run all four through Claude Code concurrently merely because Hermes quota is constrained. Use native profiles when economical, otherwise disclosed fallbacks, separate worktrees/non-overlapping files, and concise package-specific handoffs. WP-03 still follows WP-02 and WP-01; WP-04 follows WP-03, per Pi validation.

## Context and token efficiency

- Reference `result.md` and `validation.md`; do not reproduce or reread the 1,568-line plan in every assignment.
- Provide only the target WP section, its dependencies, relevant Pi corrections, ADR excerpts, and acceptance/evidence criteria.
- Use scoped Graphify output only as navigation, then verify against source.
- Require concise structured handoffs: changes, evidence, tests, decisions, risks, and reviewer eligibility.
- Reuse persisted contradiction, security-control, decision, and dependency matrices rather than regenerating them.

## Preserved human gate registry

- G1: Gerso approves the Phase 1 plan, implementation scope, and routing.
- G2: Gerso approves reconciled product and financial baselines.
- G3: Gerso approves MFA method and recovery design (D-01).
- G4: Gerso approves LLM operating mode and trust-boundary policy (D-02).
- G5: Gerso approves cloud spend, region, residency, and resource creation (D-04).
- G6: Gerso accepts Sentinel validation and release-readiness evidence, including residual-risk decision D-07.
- D-03: WCAG target before WP-13 completion.
- D-05: document/statement import scope before WP-02 closes.
- D-06: retention schedule before WP-10 closes and before release.

## G1 approval record — 2026-08-23

Gerso approved this revised routing matrix with these binding conditions:

1. Claude Code and Codex may carry the Ledger role with the documented two-runtime authorship/reviewer separation.
2. Native Hermes Sentinel remains preferred for WP-15. Sentinel/Hermes quota should be conserved for high-value security review and release-gate work.
3. Earlier Sentinel work may use an approved Claude Code or Codex fallback only when that runtime did not implement the controls it reviews.
4. Claude Code and Codex may carry the Shinobi role when native Shinobi is unavailable, quota-constrained, or uneconomical, provided Shinobi domain rules are followed and the fallback is disclosed.
5. Claude Code may carry the Archivist role when native Archivist is unavailable, quota-constrained, or uneconomical, provided Archivist documentation and evidence standards are preserved.
6. G1–G6 and D-01–D-07 remain binding. This approval closes G1 only; it does not infer any later gate decision.

No implementation or review agent was dispatched. First-wave dispatch remains blocked on the applicable decisions below and explicit orchestration assignments.

## Remaining decisions before the first implementation wave

| Decision | Required before | Recommendation |
|---|---|---|
| D-05 — document/statement upload scope | WP-02 dispatch under the validated first-wave prerequisites | Exclude upload/import from Phase 1. Record the 70% maximum reachable trust level, reconcile ADR-010 and affected product/security documents, and defer OCR, malware scanning, parsing, and TM-06/TM-07 import controls to a separately approved phase. |
| DO-06 — package naming | WP-01 creates workspace directories | Adopt ADR-019 internal names: `financial-engine`, `forecast-engine`, and `decision-engine`; retain Ledger, Oracle, and Strategist as product/domain names. Record ADR-019 as superseding conflicting ADR-002 code naming. |
| D-02 / G4 — LLM operating mode | WP-11 finalizes and before WP-12 | Select Mode A for Phase 1: deterministic server-side explanations and no external provider call carrying production data. Keep the provider abstraction and deny-by-default broker design, but defer Mode B activation to separate approval and provider/privacy evidence. WP-11 discovery can begin before this decision, but cannot close it by assumption. |
| D-04 / G5 — cloud spend, region, and residency | Any WP-14 resource creation, spend, or deployment | Permit WP-14 design only in Wave 1. Defer spend and exact region selection until WP-14 returns a costed region/residency proposal; create no cloud resources meanwhile. |

D-01/G3, D-03, D-06, and D-07/G6 are not first-wave dispatch prerequisites and remain due at their original gates. G2 remains a post-reconciliation approval gate; it is not inferred from G1.

## First-wave decision approval record — 2026-08-23

Gerso approved:

- **D-05:** document and statement upload/import is excluded from Phase 1. The maximum reachable trust level is 70%. OCR, parsing, malware scanning, and import-specific controls are deferred to a separately approved future phase. WP-02 must reconcile ADR-010 and affected product/security documentation without rewriting historical decisions.
- **DO-06:** internal package names are `financial-engine`, `forecast-engine`, and `decision-engine`. Ledger, Oracle, and Strategist remain product/domain names. ADR-019 governs and supersedes conflicting ADR-002 code naming.
- **D-02 / G4 for Phase 1:** Mode A is selected. Explanations are deterministic and server-side; no external provider call may carry production financial data. The provider abstraction and deny-by-default broker design remain in scope. Mode B stays disabled until separately approved with provider, privacy, retention, and security evidence.
- **D-04 design-only treatment:** WP-14 may produce architecture and a costed Azure region/residency proposal. No cloud resource creation, cloud spend, or deployment is authorized. G5 remains pending explicit Gerso approval.

Still pending at their original gates: D-01/G3, D-03, D-06, D-07/G6, and G2. These approvals authorize planning readiness only; they do not dispatch work.
