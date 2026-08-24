# PH1-CLD-001 Routing Reassessment

**Date:** 2026-08-23
**Status:** Approved by Gerso at G1 on 2026-08-23; implementation not dispatched
**Basis:** Existing `result.md`, Pi `validation.md`, `APPEND_SYSTEM.md`, ADR-022–ADR-025, and current specialist/runtime availability.

This artifact supplements but does not replace the original plan or validation. No implementation or review agent was dispatched.

## Current runtime-policy supersession — 2026-08-23

The original reassessment was approved under an earlier runtime policy. Its
historical approval and completed-assignment evidence remain unchanged. For all
current and future dispatch decisions, `APPEND_SYSTEM.md` supersedes its runtime
recommendations: Hermes is prohibited and must not be probed, tested, dispatched,
retried, or used as a fallback. Only Claude Code and Codex may execute the
specialist roles below.

## Rules applied

- Specialist role/domain ownership and execution runtime are separate.
- Only Claude Code and Codex are eligible execution runtimes.
- A runtime that implements a control cannot approve that control under a reviewer role. A new session of that runtime is not independent.
- Human gates G1–G6 and D-01–D-07 remain unchanged.
- If neither eligible runtime can satisfy a role or independence gate, stop and request Gerso's decision; do not weaken the gate.
- Handoffs should cite the validated plan and include only package-specific context and evidence.

## Revised routing matrix

| Work Package | Specialist Role | Preferred Runtime | Alternate Eligible Runtime | Independent Reviewer | Runtime Eligibility Condition | Human Approval Required? | Notes |
|---|---|---|---|---|---|---|---|
| WP-01 | Forge; Sentinel for repository controls | Claude Code | Codex after naming/layout design is approved | Nova; Sentinel role on an eligible runtime that did not implement reviewed controls | Preserve one eligible reviewer runtime | G2 before directories | Design may start, but directory creation waits for package naming. |
| WP-02 | Archivist; Sentinel for security-document ownership | Claude Code carrying Archivist rules | Codex for bounded documentation work | Nova; Sentinel role on the other eligible runtime when independence is required | Claude/Codex only | D-05 and G2 | Broad reconciliation normally suits Claude Code. |
| WP-03 | Ledger | Claude Code carrying Ledger rules for reconciliation | Codex when scope is bounded | Codex carrying Ledger review rules, independent of Claude; Nova; Gerso ratifies baseline | Authors and reviewers must use different eligible runtimes | G2 | No engine work until canonical fixtures pass and independent Ledger review completes. |
| WP-04 | Forge with Ledger entity semantics | Claude Code | Codex only after schema design is approved | Ledger role on a runtime not implementing WP-04; Sentinel for security controls | Preserve reviewer independence | G2 already governs baseline | Omit household functionality; any inert future column needs separate justification. |
| WP-05 | Ledger | Codex | Claude Code | Ledger-role reviewer on Claude Code; Nova | Codex implementer cannot approve | No additional human gate | Fixture conformance remains mandatory. |
| WP-06 | Forecast/Oracle under Ledger correctness | Codex | Claude Code | Ledger-role reviewer on Claude Code; Nova | Codex implementer cannot approve | No additional human gate | Same separation as WP-05. |
| WP-07 | Ledger; Archivist for product wording | Codex | Claude Code | Ledger role on Claude Code; Archivist role on an eligible independent runtime; Nova | Preserve scope-specific independence | No additional human gate | Codex implementer cannot approve financial correctness. |
| WP-08 | Sentinel control ownership; Forge implementation | Claude Code | Codex after approved auth design | Sentinel role on Codex only if Codex implemented none of the reviewed controls | Reserve Codex or stop at the review gate | G3 | Never assign Sentinel approval to the implementing runtime. |
| WP-09 | Forge; Sentinel authorization; Ledger output integrity | Claude Code | Codex for bounded handlers after design | Sentinel and Ledger roles on eligible runtimes independent of their review scopes | If both runtimes become ineligible, stop and ask Gerso | G3 remains prerequisite | Do not consume both eligible runtimes on reviewed controls without a review plan. |
| WP-10 | Sentinel control ownership; Forge implementation; Archivist evidence | Codex | Claude Code | Sentinel and Archivist roles on Claude Code only for scopes Claude did not implement | Preserve Claude review eligibility | D-06 before close/release | Codex implementer cannot provide Sentinel approval. |
| WP-11 | Sentinel trust-boundary policy; Koban constraints | Claude Code carrying Sentinel rules | Codex only if later review independence is preserved | Nova; independent Sentinel and Ledger roles on Codex | Claude authors; Codex reviews | G4 / D-02 | Completed under PH1-SEN-001; no Hermes route is permitted. |
| WP-12 | Koban with Sentinel security ownership | Claude Code | Codex after policy/design approval | Sentinel role on a runtime not implementing WP-12; Ledger reviewer for value fidelity | Reserve one eligible reviewer runtime | G4; second approval before identifiable production egress | Mode A remains default; no provider-data approval is inferred. |
| WP-13 | Interface; Archivist requirements; Sentinel client security | Claude Code | Codex after UX architecture approval | Archivist and Sentinel roles, each independent of implementation for their approval scope | Preserve one eligible reviewer runtime | D-03 before completion | Keep implementation on one runtime when the other is needed for review. |
| WP-14 | Shinobi; Sentinel security | Claude Code carrying Shinobi rules | Codex for bounded modules | Sentinel role on an eligible runtime independent of infrastructure implementation; Nova | If both runtimes become ineligible, stop and ask Gerso | G5 before resources, spend, or deployment | Hermes is prohibited; plan implementation/review separation before dispatch. |
| WP-15 | Sentinel independent pre-release validation | Codex carrying Sentinel rules if Codex remains untouched by reviewed controls | Claude Code carrying Sentinel rules if Claude remains untouched by reviewed controls | Nova validates identity/evidence; Gerso accepts or rejects release risk | Use an untouched eligible runtime; if neither is eligible, stop and request Gerso's decision | G6 / D-07 | Hermes is prohibited. Runtime allocation must preserve a Claude Code or Codex reviewer before implementation proceeds. |
| WP-16 | Nova coordination; Archivist evidence; Sentinel privacy; Ledger accuracy | Codex for instrumentation; human study | Claude Code for instrumentation | Specialist roles on eligible runtimes independent of reviewed work | Claude/Codex only | G6 | The study remains human work; no runtime may fabricate usability evidence. |

## Runtime conclusions

### Eligible runtimes

Only Claude Code and Codex may execute these specialist roles. Hermes is
prohibited and has no preferred, native, emergency, retry, or fallback status.
Runtime separation must be reserved before implementation begins.

### Independence failure

If both Claude Code and Codex implement controls inside a required independent
review scope, neither runtime is eligible to approve that scope. A new session
does not restore independence. Stop and request Gerso's decision rather than
probing another runtime or weakening WP-15/G6.

### Claude Code use

Claude Code remains preferred for broad design and multi-file work: WP-01, WP-04, WP-08, WP-09, WP-12, WP-13, and broad WP-14 work. It is the recommended fallback for Archivist WP-02, Sentinel WP-11, and Ledger WP-03 when carrying those profiles/domain rules explicitly.

### Codex use

Codex remains preferred for bounded, fixture-driven implementation: WP-05–WP-07, WP-10, and WP-16 instrumentation. It may handle bounded portions of WP-01, WP-04, WP-08, WP-09, WP-12–WP-14 after design approval. It may serve as an independent Sentinel fallback only for controls it did not implement, and as a Ledger reviewer only when Claude Code performed the financial work.

## Sentinel independence

- Sentinel remains the required role for ADR-024 validation.
- Only Claude Code or Codex may carry that role.
- Every security assignment records the implementing runtime(s).
- A runtime is ineligible to approve any control it implemented, even in a new session or under a Sentinel prompt.
- Reserve one eligible runtime from security implementation and assign it the Sentinel domain rules, evidence requirements, and final verdict duty.
- If no eligible independent runtime remains, stop and request Gerso's decision.
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

1. WP-02: Claude Code carrying Archivist rules; reserve Codex for independent bounded review where needed.
2. WP-11: Claude Code carrying Sentinel rules; Codex performs independent Sentinel and Ledger review if eligibility remains intact.
3. WP-01: Claude Code. Design may start; no package directories before G2 naming resolution.
4. WP-14: Claude Code carrying Shinobi rules; Codex may handle bounded modules or independent review, but not both for the same scope.

Use separate worktrees/non-overlapping files and concise package-specific handoffs. Plan Claude/Codex implementation and review allocation before dispatch so WP-15 independence remains possible. WP-03 still follows WP-02 and WP-01; WP-04 follows WP-03, per Pi validation.

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
2. **Superseded runtime condition:** the original approval preferred native Hermes Sentinel for WP-15. Current `APPEND_SYSTEM.md` policy prohibits Hermes. WP-15 must use an untouched Claude Code or Codex runtime carrying Sentinel rules; if neither is eligible, stop and request Gerso's decision.
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
