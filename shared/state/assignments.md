# Ninjatronics AI Assignment Ledger

## Purpose

This ledger is the authoritative record of multi-agent assignments coordinated by Nova.

It exists to preserve:

- Unique assignment IDs
- Ownership
- Current workflow state
- Dependencies
- Approval gates
- Specialist handoffs
- Review status
- Evidence references
- Final disposition

Conversation history is not the source of truth. This file is.

---

## Operating rules

1. Nova must read this ledger before creating a new assignment ID.
2. Assignment IDs must never be reused.
3. Existing assignment IDs must not be renamed.
4. Every assignment must have one accountable owner.
5. Status changes must be recorded explicitly.
6. Planned work must not be marked dispatched without transport evidence.
7. Dispatched work must not be marked complete without a specialist handoff.
8. Complete work must not be marked reviewed without a review artifact.
9. Reviewed work must not be marked approved without the required approval.
10. Closed assignments must retain their full history.
11. Assignments must not be deleted. Cancelled work remains in the ledger.
12. Material status changes should include a date and evidence reference.
13. Nova may maintain this ledger as part of normal orchestration, but must never fabricate status, evidence, review, approval, or completion.
14. Production, security, compliance, credential, financial, destructive, and irreversible work requires Gerso approval where defined by the orchestration standard.

---

## Assignment ID format

Use:

```text
<project-or-phase>-<owner-code>-<sequence>
```

Examples:

```text
PH6-NOV-001
PH6-SHI-001
PH6-SEN-001
PH6-ARC-001
PH6-CLD-001
PH6-COD-001
```

Owner codes:

| Code | Owner |
|---|---|
| NOV | Nova |
| SHI | Shinobi |
| SEN | Sentinel |
| ARC | Archivist |
| CLD | Claude Code |
| COD | Codex |

Sequence numbers are tracked independently for each project or phase and owner code.

Before minting a new ID, Nova must search this ledger for the highest existing sequence for that prefix and increment it by one.

Example:

```text
Highest existing ID: PH6-SHI-004
Next valid ID:       PH6-SHI-005
```

---

## Allowed assignment states

Use only these states:

| State | Meaning |
|---|---|
| Draft | The assignment is being written |
| Awaiting clarification | Material information is missing |
| Ready to dispatch | The assignment is complete and dependencies are satisfied |
| Dispatched | The assignment was sent to the owner |
| In progress | The owner acknowledged or began the work |
| Blocked | The work cannot proceed |
| Awaiting review | A specialist handoff was received and review is required |
| Remediation required | A reviewer returned findings requiring changes |
| Awaiting approval | Required technical or human approval is pending |
| Complete | Assigned deliverables and validation were returned |
| Closed | Review, evidence, approvals, documentation, and closure are complete |
| Cancelled | Work was intentionally stopped |

The following states are not interchangeable:

```text
Complete != Reviewed != Approved != Closed
```

---

## Priority values

Use only:

- Low
- Normal
- High
- Urgent

Priority does not override approval gates or safety requirements.

---

## Assignment summary

This table provides the current state of all assignments.

| Assignment ID | Title | Owner | Priority | Status | Depends on | Reviewer | Approval required | Last updated |
|---|---|---|---|---|---|---|---|---|
| LAB-ABS-SEN-001 | Independent security review of PR #6 (Audiobookshelf GitOps) | Sentinel (live Herdr dispatch) | High | Complete — Nova-validated (verdict PASS WITH NOTES; transport exit 0; identity verified) | None | Nova | None — evidence artifact retained | 2026-07-28 |
| LAB-ABS-ARC-001 | Merge and cutover evidence checklist for Audiobookshelf PR #6 | Archivist (live Herdr dispatch) | High | Complete — Nova-validated (verdict Complete with findings; transport exit 0; identity verified; checklist + supporting doc evidence) | LAB-ABS-SEN-001 | Nova | None — evidence artifact retained | 2026-07-28 |
| PH6-SEN-001 | Independent security review of feat/audiobookshelf | Sentinel (fallback: delegated subagent deleg_a47f68e5) | High | Reviewed — accepted by Nova (verdict PASS; evidence independently re-validated) | None | Sentinel | Gerso (merge gate) | 2026-07-28 |
| PH6-COD-001 | Remediate Sentinel BLOCKER/HIGH findings on feat/audiobookshelf | Codex (fallback: delegated subagent) | High | Cancelled (no BLOCKER/HIGH findings) | PH6-SEN-001 | Sentinel (re-review) | Gerso (merge gate) | 2026-07-28 |
| PH6-ARC-001 | Documentation for Audiobookshelf deployment | Archivist (fallback: delegated subagent deleg_1d2cb368) | Normal | Complete — accepted by Nova (commit 7cf3fc7; evidence validated) | PH6-SEN-001 | Nova | None | 2026-07-28 |
| PH6-CLD-001 | Herdr v0.7.5 contract discovery for Nova→Herdr→specialist transport | Claude Code (runtime; deleg_1cd1fe0e) | High | Complete — accepted by Nova (contract proven end-to-end via live probe; evidence in transcript) | None | Nova | Gerso (plan approval before Phase 2) | 2026-07-28 |
| PH6-COD-002 | Implement Nova→Herdr→specialist transport (dispatch-specialist.sh + libs + docs); optional `hermes -z` spike | Codex (runtime) | High | Complete — Nova-reviewed & live-validated (TEST A/B/C/D pass; Nova fixed 3 integration bugs: stderr error-parse, whole-line markers, teardown verify) | PH6-CLD-001 | Nova | Gerso (merge gate) | 2026-07-28 |
| PH1-CLD-001 | Zaifu Phase 1 sequenced implementation plan | Claude Code (Herdr runtime) | High | Tranche 1 complete and integrated; Tranche 2 awaiting Gerso approval | Phase 0 gate approval; ADR-022–ADR-025 | Active orchestrator | Gerso (Tranche 2 dispatch not authorized) | 2026-08-23 |
| PH1-ARC-001 | WP-02 authoritative baseline reconciliation | Archivist role on Claude Code (approved fallback) | High | Complete — Nova-validated and integrated with findings | G1; D-05; DO-06; D-02/G4 Mode A | Active orchestrator; PH1-SEN-002 later | G2 remains pending | 2026-08-23 |
| PH1-CLD-002 | WP-01 monorepo foundation and toolchain | Forge role on Claude Code | High | Complete — Nova-validated and integrated with findings | G1; DO-06 | Active orchestrator; PH1-SEN-002 later | G2 remains pending | 2026-08-23 |
| PH1-SHI-001 | WP-14 platform architecture and cost/residency proposal | Shinobi role on Claude Code (approved fallback) | High | Complete — Nova-validated and integrated with findings | G1; D-04 design-only authorization | Active orchestrator; PH1-SEN-002 later | G5 remains pending | 2026-08-23 |

---

## Phase 6 Herdr transport — live validation evidence (PH6-COD-002)

Real Nova→Herdr→specialist launches through `scripts/dispatch-specialist.sh`.
All ran real named Hermes profiles (identity verified via argv + live cmdline +
specialist-declared PROFILE_IDENTITY). No delegate_task fallback in any run.
Artifacts persist under `shared/handoffs/<id>/`.

| Test | Assignment | Profile | Herdr pane / ws / tab / terminal | Exit | Result |
|---|---|---|---|---|---|
| A (Sentinel) | PH6-SEN-SMOKE-006 | sentinel | wN:p1 / wN / wN:t1 / term_657ac90ea3b171a | 0 | result.md 857B; identity 3-way; teardown verified |
| C (timeout) | PH6-C5-TIMEOUT | sentinel | wQ:p1 / wQ / wQ:t1 / term_657ac94cf8f901c | 124 | error.code=timeout recorded; agent torn down |
| C (validation) | (unit) invalid profile→64, missing prompt→66, unsafe id→64, bad timeout→2 | — | — | 64/66/2 | scripts/test-dispatch.sh: 16/16 pass |
| D (Sentinel) | PH6-TESTD-SEN-001 | sentinel | wR:p1 / wR / wR:t1 / term_657ac9e4ab0ce1d | 0 | REMEDIATION_REQUIRED: no; Nova consumed |
| D (Archivist) | PH6-TESTD-ARC-001 | archivist | wS:p1 / wS / wS:t1 / term_657aca1ae6d4f1e | 0 | decision-record summary; Nova consumed |

Conditional routing (TEST D): Nova dispatched Sentinel → consumed result →
extracted "REMEDIATION_REQUIRED: no" → correctly did NOT dispatch Codex →
dispatched Archivist to document → consumed summary. Real Herdr transport both
legs.

`-z` spike verdict: passes a,b,c,d,e,g,h but FAILS f (not visible/manageable
through Herdr — headless subprocess). Marker-based interactive transport
retained as PRIMARY; `-z` kept as secondary (`--transport zexec`).

### Nova re-verification pass + chrome-strip remediation (2026-07-28)

Nova re-verified the transport against the currently-running Herdr v0.7.5
server before commit. Live syntax re-confirmed via `herdr --help` (workspace
create / agent start / agent prompt / pane wait-output all match the wrappers).

| Test | Assignment | Profile | Herdr pane / ws / tab / terminal | Exit | Result |
|---|---|---|---|---|---|
| Re-verify (post-fix) | PH6-ARC-SMOKE-004 | archivist | wW:p1 / wW / wW:t1 / term_657b04410c5bd21 | 0 | done; identity 3-way; teardown verified; result body CLEAN (no chrome). |

A pre-fix re-verification run first surfaced the TUI cost-cap line leaking into
the result body; its probe artifact was discarded after the fix and is not
retained. PH6-ARC-SMOKE-004 above is the retained, post-fix Archivist
live-success evidence.

Evidence set retained in-repo (trimmed to unique required behavior; superseded
and duplicate smoke runs pruned): PH6-SEN-SMOKE-006 (Sentinel live success),
PH6-ARC-SMOKE-004 (Archivist live success, clean body), PH6-C5-TIMEOUT
(timeout handling → exit 124), PH6-TESTD-SEN-001 + PH6-TESTD-ARC-001
(conditional routing across both legs).

Remediation: added `marker_strip_chrome` in `scripts/lib/markers.sh`, invoked
from `extract_and_finish` in `dispatch-specialist.sh`, to drop interleaved
Hermes TUI chrome (the `• You've used $X of your $Y cap` status bar) that can
render between the result markers in the rendered scrollback. Marker
validation and exit-code logic are unchanged; only the persisted evidence body
is scrubbed. New unit test (section D) added to `scripts/test-dispatch.sh`;
suite now **18/18 pass**. No delegate_task used in any run.

---

## Zaifu Phase 0 gate approval — 2026-08-23

Gerso approved the Zaifu Phase 0 gate and authorized Phase 1 planning. Binding
constraints are recorded in Zaifu `docs/planning/PHASE_0_GATE_REVIEW.md` and
ADR-022 through ADR-025:

- MFA is required for the MVP baseline.
- External LLM providers are an explicit trust boundary; production financial
  data is denied by default and identifiable production data requires explicit
  future approval.
- Sentinel owns independent pre-release security validation; implementers may
  not approve their own controls.
- Household and multi-user functionality remain out of Phase 1 scope unless
  explicitly authorized and require a new authorization design and threat model.

This approval record does not backfill or reconcile historical Phase 0
assignment entries.

---

## Active assignments

Assignments remain in this section until they are Closed or Cancelled.

### `PH1-CLD-001` — `Zaifu Phase 1 sequenced implementation plan`

#### Metadata

| Field | Value |
|---|---|
| Assignment ID | `PH1-CLD-001` |
| Owner | `Claude Code` |
| Requested by | `Pi acting as active orchestrator (Nova role)` |
| Priority | `High` |
| Status | `Tranche 1 complete and integrated; Tranche 2 awaiting approval` |
| Created | `2026-08-23` |
| Last updated | `2026-08-23` |
| Reviewer | `Active orchestrator` |
| Approval required | `Gerso before Tranche 2 dispatch` |
| Recommended next owner | `Gerso` |

#### Objective

Convert the approved Zaifu Phase 0 architecture, requirements, security
constraints, and owner decisions into a sequenced Phase 1 implementation plan
with bounded, routable work packages.

#### Context

- Phase 0 gate approved by Gerso on 2026-08-23.
- ADR-022 through ADR-025 are binding Phase 1 constraints.
- Implementation must not begin until Gerso approves the returned plan.

#### Scope

- Read-only analysis of `/home/gerso/Development/zaifu` planning, product,
  architecture, security, and orchestration documentation.
- Work-package sequencing, dependencies, routing, validation, evidence, review,
  and approval gates.

#### Out of scope

- Application or infrastructure implementation.
- File modifications by Claude Code.
- Follow-up dispatches.
- Historical Phase 0 orchestration reconciliation.

#### Inputs

- `shared/handoffs/PH1-CLD-001/assignment.md`
- Zaifu Phase 0 gate review and ADR-022 through ADR-025.
- Ninjatronics routing, orchestration, collaboration, and security standards.

#### Constraints

- Strictly read-only.
- No code, schema, configuration, test, branch, worktree, commit, or PR changes.
- No household/multi-user scope.
- No assumption that external providers may process production financial data.

#### Required deliverables

- Sequenced bounded work packages with dependencies and critical path.
- Claude Code versus Codex routing recommendation.
- Sentinel review and security-evidence matrix.
- LLM trust-boundary planning requirements.
- Additional Gerso decision register.
- Recommended first implementation wave without dispatching it.

#### Validation required

- Source traceability and before/after clean Git status.
- Every package includes scope, dependencies, acceptance, validation, evidence,
  owner/runtime, review, and approval requirements.
- No implementation performed.

#### Evidence required

- Source paths/sections, read-only commands, Git status, requirement/ADR/control
  traceability, and explicit no-modification statement.

#### Dependencies

- Zaifu Phase 0 gate approval — satisfied 2026-08-23.
- ADR-022 through ADR-025 — recorded.

#### Escalation conditions

- Material source conflicts, missing architecture decisions, provider-data
  authorization needs, household scope, or unassignable independent review.

#### Completion criteria

- Complete implementation-ready planning handoff returned and validated.
- Gerso receives the plan before any implementation dispatch.

#### Fallback runtime disclosure

| Field | Value |
|---|---|
| Specialist role simulated | `None` |
| Runtime used | `Claude Code` |
| Reason for fallback | `None` |
| Independent review still required | `Yes — active orchestrator validation; Gerso plan approval` |

#### Status history

| Date | Previous state | New state | Changed by | Reason | Evidence |
|---|---|---|---|---|---|
| `2026-08-23` | `—` | `Draft` | `Pi / active orchestrator` | Assignment created | `shared/handoffs/PH1-CLD-001/assignment.md` |
| `2026-08-23` | `Draft` | `Ready to dispatch` | `Pi / active orchestrator` | Scope and acceptance criteria validated | `shared/handoffs/PH1-CLD-001/assignment.md` |
| `2026-08-23` | `Ready to dispatch` | `Dispatched` | `Pi / active orchestrator` | Started real Claude Code runtime through Herdr | `shared/handoffs/PH1-CLD-001/transport.json` |
| `2026-08-23` | `Dispatched` | `In progress` | `Pi / active orchestrator` | Herdr observed Claude working on the assignment | Herdr agent `zaifu_phase1_planner`, pane `w1B:p4` |
| `2026-08-23` | `In progress` | `Awaiting review` | `Pi / active orchestrator` | Complete 1,568-line planning handoff returned | `shared/handoffs/PH1-CLD-001/result.md` |
| `2026-08-23` | `Awaiting review` | `Awaiting approval` | `Pi / active orchestrator` | Handoff accepted with six synthesis corrections; implementation remains blocked | `shared/handoffs/PH1-CLD-001/validation.md` |
| `2026-08-23` | `Awaiting approval` | `Approved at G1` | `Gerso` | Approved revised routing, Ledger separation, conditional Sentinel/Shinobi/Archivist fallbacks; preserved G1–G6 and D-01–D-07 | `shared/handoffs/PH1-CLD-001/routing-reassessment.md` |
| `2026-08-23` | `Approved at G1` | `Wave 1 ready — awaiting dispatch approval` | `Gerso / active orchestrator` | D-05, DO-06, D-02/G4 Mode A, and D-04 design-only approved; readiness reassessed; no dispatch | `routing-reassessment.md`; `first-wave-proposal.md`; Zaifu `DECISION_LOG.md` addendum |
| `2026-08-23` | `Wave 1 ready — awaiting dispatch approval` | `Tranche 1 in progress` | `Gerso / active orchestrator` | Gerso authorized PH1-ARC-001, PH1-CLD-002, and design-only PH1-SHI-001 with selected runtimes | Assignment and transport artifacts under `shared/handoffs/` |
| `2026-08-23` | `Tranche 1 in progress` | `Tranche 1 complete and integrated; Tranche 2 awaiting approval` | `Pi / active orchestrator` | Handoffs independently validated, integrated in dependency order, repository-wide validation passed, and Codex eligibility preserved | `shared/handoffs/PH1-CLD-001/tranche-1-results.md` |

#### Dispatch record

| Field | Value |
|---|---|
| Dispatch method | `Herdr` |
| Dispatched to | `Claude Code` |
| Dispatched by | `Pi / active orchestrator` |
| Date | `2026-08-23` |
| Transport evidence | `shared/handoffs/PH1-CLD-001/transport.json`; agent `zaifu_phase1_planner`; pane `w1B:p4`; workspace `w1B`; tab `w1B:t1`; terminal `term_659bdd3a69e0d2b`; Claude session `f95ab690-6227-44a0-9d02-67fc1d881326` |

#### Specialist handoff

| Field | Value |
|---|---|
| Handoff received | `Yes` |
| Handoff path or reference | `shared/handoffs/PH1-CLD-001/result.md` |
| Reported status | `Complete with findings` |
| Evidence validated by | `Pi / active orchestrator` |
| Evidence validation result | `Accepted with six synthesis corrections` |

#### Review record

| Field | Value |
|---|---|
| Reviewer | `Active orchestrator` |
| Review status | `Passed with findings` |
| Review artifact | `shared/handoffs/PH1-CLD-001/validation.md` |
| Routing reassessment | `shared/handoffs/PH1-CLD-001/routing-reassessment.md` — G1 and first-wave decisions approved by Gerso on 2026-08-23 |
| Wave 1 proposal | `shared/handoffs/PH1-CLD-001/first-wave-proposal.md` — Tranche 1 executed; Tranche 2 remains unapproved |
| Tranche 1 result | `shared/handoffs/PH1-CLD-001/tranche-1-results.md` |
| Critical findings open | `0` |
| High findings open | `0` |
| Moderate findings open | `6 planning corrections applied in synthesis` |
| Low findings open | `0` |
| Remediation assignment | `None` |

#### Approval record

| Field | Value |
|---|---|
| Approval required | `Yes` |
| Approver | `Gerso` |
| Decision | `G1 and Tranche 1 approved and executed under stated conditions; Tranche 2 is not authorized` |
| Date | `2026-08-23` |
| Approval evidence | `shared/handoffs/PH1-CLD-001/routing-reassessment.md`; Zaifu `docs/planning/DECISION_LOG.md` Phase 1 Owner Decision Addendum |

#### Risks and outstanding work

- Source contradictions may require explicit resolution before implementation.
- Financial correctness ownership must remain explicit in package routing.
- The Ledger fallback is approved with independent Claude/Codex authorship-review separation; lack of a native Ledger runtime is not itself a role blocker.
- Earlier Sentinel fallbacks are approved only when the fallback runtime implemented none of the controls it reviews; native Hermes Sentinel remains preferred for WP-15.
- Claude/Codex Shinobi fallback and Claude Archivist fallback are approved under the disclosure and domain-rule conditions in the reassessment.
- D-05, DO-06, D-02/G4 Mode A, and D-04 design-only treatment are approved and persisted.
- G2, D-01/G3, D-03, D-06, D-07/G6, and resource/spend approval at G5 remain pending at their existing gates.
- Tranche 1 is integrated and validated. PH1-SEN-001, PH1-SEN-002, and PH1-COD-001 remain undispatched pending Gerso approval.
- PH1-ARC-001 left two excluded legacy package-path references and surfaced a trust-ceiling/answer-threshold question for WP-03/G2.
- PH1-CLD-002 cannot enable hosted secret scanning or branch protection until a repository host and any required spend are approved.
- PH1-SHI-001 found that D-04/G5 must jointly decide region, residency, backup redundancy, key-management posture, and spend before resource creation.

#### Closure record

| Field | Value |
|---|---|
| Closure status | `Open` |
| Closed by | `—` |
| Closure date | `Open` |
| Final synthesis | `shared/handoffs/PH1-CLD-001/validation.md`; approved routing/decision supplement at `routing-reassessment.md`; proposed execution at `first-wave-proposal.md` |
| Evidence index | `shared/handoffs/PH1-CLD-001/` |
| Residual risk | `Ledger separation and Sentinel fallback eligibility must be enforced per assignment. G2, G3, G5 resource approval, G6, D-01, D-03, D-06, and D-07 remain pending.` |

### `PH1-ARC-001` — `WP-02 authoritative baseline reconciliation`

#### Metadata

| Field | Value |
|---|---|
| Assignment ID | `PH1-ARC-001` |
| Owner | `Archivist role on Claude Code — intentional approved fallback to conserve Hermes quota` |
| Requested by | `Pi / active orchestrator` |
| Priority | `High` |
| Status | `Complete` |
| Created / updated | `2026-08-23` |
| Reviewer | `Active orchestrator; PH1-SEN-002 when authorized` |
| Approval required | `G2 remains pending` |
| Recommended next owner | `PH1-SEN-002 after Gerso authorization` |

#### Objective, scope, and evidence

Implement WP-02 documentation reconciliation in an isolated Zaifu worktree. Exclusive ownership is bounded in `shared/handoffs/PH1-ARC-001/assignment.md`; financial rules, LLM policy, platform docs, code, and cloud actions are excluded. Required evidence includes contradiction closure, history preservation, links/searches, changed-file boundary, commit, and no-cloud attestation.

#### Dependencies and constraints

G1, D-05, DO-06, and D-02/G4 Mode A are satisfied. G2 remains open. The runtime must preserve all Archivist evidence rules and may not invent approvals or evidence.

#### Fallback runtime disclosure

| Field | Value |
|---|---|
| Specialist role simulated | `Archivist` |
| Runtime used | `Claude Code` |
| Reason for fallback | `Intentional Gerso-approved fallback to conserve native Hermes quota` |
| Independent review still required | `Yes — active orchestrator; PH1-SEN-002 for security-document changes` |

#### Status history

| Date | Previous state | New state | Changed by | Reason | Evidence |
|---|---|---|---|---|---|
| `2026-08-23` | `—` | `Draft` | `Pi / active orchestrator` | Assignment created | `shared/handoffs/PH1-ARC-001/assignment.md` |
| `2026-08-23` | `Draft` | `Ready to dispatch` | `Pi / active orchestrator` | Gerso approved Tranche 1 and selected Claude fallback | User approval; assignment artifact |
| `2026-08-23` | `Ready to dispatch` | `Dispatched` | `Pi / active orchestrator` | Claude/Archivist fallback started in isolated Herdr worktree | `shared/handoffs/PH1-ARC-001/transport.json` |
| `2026-08-23` | `Dispatched` | `In progress` | `Pi / active orchestrator` | Herdr observed live work; initial wait timeout recorded without treating it as failure | Herdr agent `ph1_arc_001` |
| `2026-08-23` | `In progress` | `Awaiting review` | `Pi / active orchestrator` | Committed handoff received | `result.md`; Zaifu commit `1979835` |
| `2026-08-23` | `Awaiting review` | `Complete` | `Pi / active orchestrator` | Independently validated and integrated as `ee41276`; findings retained | `validation.md` |

#### Dispatch, handoff, and review record

- Herdr: agent `ph1_arc_001`, workspace `w1D`, pane `w1D:p1`, terminal `term_659bf0b0e917e2d`; exit 0 after timeout recovery.
- Handoff: `shared/handoffs/PH1-ARC-001/result.md`; validation: `validation.md`.
- Verdict: passed with findings. Minor scope breach recorded: the runtime wrote two benign validation scripts outside its worktree and inaccurately attested that Ninjatronics was untouched. Legacy names remain in two excluded files; Sentinel review and G2 remain pending.
- Closure: open pending authorized independent review and later gate disposition.

### `PH1-CLD-002` — `WP-01 monorepo foundation and toolchain`

#### Metadata

| Field | Value |
|---|---|
| Assignment ID | `PH1-CLD-002` |
| Owner | `Forge role on Claude Code` |
| Requested by | `Pi / active orchestrator` |
| Priority | `High` |
| Status | `Complete` |
| Created / updated | `2026-08-23` |
| Reviewer | `Active orchestrator; PH1-SEN-002 when authorized` |
| Approval required | `G2 remains pending` |
| Recommended next owner | `PH1-SEN-002 after Gerso authorization` |

#### Objective, scope, and evidence

Implement WP-01's pnpm/TypeScript workspace, CI foundation, and minimal scaffolds in an isolated Zaifu worktree. Exclusive paths, strict no-feature/no-cloud bounds, validation, and evidence are defined in `shared/handoffs/PH1-CLD-002/assignment.md`.

#### Dependencies and constraints

G1 and DO-06 are satisfied. Codex is reserved and may not be used. The assignment must report hosted repository controls rather than fabricate them.

#### Fallback runtime disclosure

| Field | Value |
|---|---|
| Specialist role simulated | `Forge` |
| Runtime used | `Claude Code` |
| Reason for fallback | `Approved proposed runtime; no native Forge runtime is required` |
| Independent review still required | `Yes — active orchestrator; PH1-SEN-002 for repository/CI controls` |

#### Status history

| Date | Previous state | New state | Changed by | Reason | Evidence |
|---|---|---|---|---|---|
| `2026-08-23` | `—` | `Draft` | `Pi / active orchestrator` | Assignment created | `shared/handoffs/PH1-CLD-002/assignment.md` |
| `2026-08-23` | `Draft` | `Ready to dispatch` | `Pi / active orchestrator` | Gerso approved Tranche 1 | User approval; assignment artifact |
| `2026-08-23` | `Ready to dispatch` | `Dispatched` | `Pi / active orchestrator` | Claude/Forge started in isolated Herdr worktree | `shared/handoffs/PH1-CLD-002/transport.json` |
| `2026-08-23` | `Dispatched` | `Awaiting review` | `Pi / active orchestrator` | Two committed handoff commits returned | `result.md`; commits `919b097`, `b81bf56` |
| `2026-08-23` | `Awaiting review` | `Complete` | `Pi / active orchestrator` | Fresh-archive validation passed and result integrated as `3315e65`, `2df8931` | `validation.md` |

#### Dispatch, handoff, and review record

- Herdr: agent `ph1_cld_002`, workspace `w1E`, pane `w1E:p1`, terminal `term_659bf0b0edb622e`; exit 0.
- Handoff: `shared/handoffs/PH1-CLD-002/result.md`; validation: `validation.md`.
- Verdict: passed with findings. Frozen install and all 9 tests passed; hosted scanning/protection remain unavailable and unclaimed.
- Closure: open pending authorized independent review and later gate disposition.

### `PH1-SHI-001` — `WP-14 platform architecture and cost/residency proposal`

#### Metadata

| Field | Value |
|---|---|
| Assignment ID | `PH1-SHI-001` |
| Owner | `Shinobi role on Claude Code — approved fallback` |
| Requested by | `Pi / active orchestrator` |
| Priority | `High` |
| Status | `Complete` |
| Created / updated | `2026-08-23` |
| Reviewer | `Active orchestrator; PH1-SEN-002 when authorized` |
| Approval required | `G5 remains pending` |
| Recommended next owner | `PH1-SEN-002 after Gerso authorization; Gerso at later G5` |

#### Objective, scope, and evidence

Produce design-only WP-14 architecture and cost/residency options in exactly four new owned documents. `shared/handoffs/PH1-SHI-001/assignment.md` prohibits credentials, authenticated consoles, resource creation, deployment, DNS, spend, IaC, and existing-file edits.

#### Dependencies and constraints

D-04 authorizes design only. Application-interface assumptions must be verified against PH1-CLD-002 after return or explicitly left pending. G5 remains closed.

#### Fallback runtime disclosure

| Field | Value |
|---|---|
| Specialist role simulated | `Shinobi` |
| Runtime used | `Claude Code` |
| Reason for fallback | `Approved fallback; native Shinobi is not in validated dispatcher allow-list and broad design suits Claude Code` |
| Independent review still required | `Yes — active orchestrator; PH1-SEN-002 for security controls` |

#### Status history

| Date | Previous state | New state | Changed by | Reason | Evidence |
|---|---|---|---|---|---|
| `2026-08-23` | `—` | `Draft` | `Pi / active orchestrator` | Assignment created | `shared/handoffs/PH1-SHI-001/assignment.md` |
| `2026-08-23` | `Draft` | `Ready to dispatch` | `Pi / active orchestrator` | Gerso approved design-only Tranche 1 fallback | User approval; assignment artifact |
| `2026-08-23` | `Ready to dispatch` | `Dispatched` | `Pi / active orchestrator` | Claude/Shinobi fallback started in isolated Herdr worktree | `shared/handoffs/PH1-SHI-001/transport.json` |
| `2026-08-23` | `Dispatched` | `In progress` | `Pi / active orchestrator` | Herdr observed public research/design; initial wait timeout recorded | Herdr agent `ph1_shi_001` |
| `2026-08-23` | `In progress` | `Awaiting review` | `Pi / active orchestrator` | Initial handoff plus WP-01 interface reconciliation returned | `result.md`; commits `73ac771`, `00185e2` |
| `2026-08-23` | `Awaiting review` | `Complete` | `Pi / active orchestrator` | Exact boundary/source claims validated and integrated as `f530a7a`, `ae8d873` | `validation.md` |

#### Dispatch, handoff, and review record

- Herdr: agent `ph1_shi_001`, workspace `w1F`, pane `w1F:p1`, terminal `term_659bf0b0f240d2f`; exit 0 after timeout recovery and bounded follow-up.
- Handoff: `shared/handoffs/PH1-SHI-001/result.md`; validation: `validation.md`.
- Verdict: passed with findings. Exact four-file boundary and no prohibited action verified; G5 remains closed.
- Closure: open pending authorized independent review and later G5 disposition.

Copy the template below for each additional active assignment.

### `<ASSIGNMENT-ID>` — `<Short title>`

#### Metadata

| Field | Value |
|---|---|
| Assignment ID | `<ASSIGNMENT-ID>` |
| Owner | `<Nova / Shinobi / Sentinel / Archivist / Claude Code / Codex>` |
| Requested by | `Nova` |
| Priority | `<Low / Normal / High / Urgent>` |
| Status | `<Allowed state>` |
| Created | `<YYYY-MM-DD>` |
| Last updated | `<YYYY-MM-DD>` |
| Reviewer | `<Owner or Not assigned>` |
| Approval required | `<Gerso / Sentinel / Nova / None>` |
| Recommended next owner | `<Owner>` |

#### Objective

`<Exact outcome expected>`

#### Context

- `<Relevant background needed to understand the assignment>`

#### Scope

- `<Included repository, files, systems, environment, or data>`

#### Out of scope

- `<Explicit exclusions>`

#### Inputs

- `<Required documents, paths, decisions, logs, or prior handoffs>`

#### Constraints

- `<Read-only, no file modifications, no production changes, etc.>`

#### Required deliverables

- `<Deliverable>`

#### Validation required

- `<Test, review, or verification requirement>`

#### Evidence required

- `<Command output, file path, diff, commit, log, screenshot, report, etc.>`

#### Dependencies

- `<Assignment ID, approval, or external prerequisite>`
- `None` when no dependency exists.

#### Escalation conditions

- `<Condition requiring Nova or Gerso>`

#### Completion criteria

- `<Condition that must be true before Complete status>`

#### Fallback runtime disclosure

| Field | Value |
|---|---|
| Specialist role simulated | `<Role or None>` |
| Runtime used | `<Claude Code / Codex / Other / None>` |
| Reason for fallback | `<Reason or None>` |
| Independent review still required | `<Yes / No>` |

#### Status history

| Date | Previous state | New state | Changed by | Reason | Evidence |
|---|---|---|---|---|---|
| `<YYYY-MM-DD>` | `—` | `Draft` | `Nova` | `Assignment created` | `<Path or reference>` |

#### Dispatch record

| Field | Value |
|---|---|
| Dispatch method | `<Manual relay / Herdr / Claude Code CLI / Codex CLI / Other>` |
| Dispatched to | `<Agent, profile, or runtime>` |
| Dispatched by | `<Nova / Gerso>` |
| Date | `<YYYY-MM-DD or Not dispatched>` |
| Transport evidence | `<Herdr handle, session reference, transcript path, or Not dispatched>` |

#### Specialist handoff

| Field | Value |
|---|---|
| Handoff received | `<Yes / No>` |
| Handoff path or reference | `<Path or reference>` |
| Reported status | `<Complete / Complete with findings / Blocked / Requires clarification / Failed>` |
| Evidence validated by | `<Owner or Not yet validated>` |
| Evidence validation result | `<Accepted / Rejected / Partial / Pending>` |

#### Review record

| Field | Value |
|---|---|
| Reviewer | `<Sentinel / Claude Code / Codex / Nova / Other>` |
| Review status | `<Not started / In progress / Passed / Passed with findings / Failed>` |
| Review artifact | `<Path or reference>` |
| Critical findings open | `<Number>` |
| High findings open | `<Number>` |
| Moderate findings open | `<Number>` |
| Low findings open | `<Number>` |
| Remediation assignment | `<Assignment ID or None>` |

#### Approval record

| Field | Value |
|---|---|
| Approval required | `<Yes / No>` |
| Approver | `<Gerso / Sentinel / Nova / Other>` |
| Decision | `<Pending / Approved / Rejected / Approved with conditions>` |
| Date | `<YYYY-MM-DD or Pending>` |
| Approval evidence | `<Reference>` |

#### Risks and outstanding work

- `<Known risk, deferred item, or unresolved question>`

#### Closure record

| Field | Value |
|---|---|
| Closure status | `<Open / Closed / Cancelled>` |
| Closed by | `<Nova / Gerso>` |
| Closure date | `<YYYY-MM-DD or Open>` |
| Final synthesis | `<Path or reference>` |
| Evidence index | `<Path or reference>` |
| Residual risk | `<Summary or None>` |

---

## Closed assignments

Move an assignment from Active assignments to this section only after:

- Deliverables were returned
- Validation was completed
- Required review was completed
- Findings were resolved or formally accepted
- Evidence was indexed
- Required approval was recorded
- Nova issued final synthesis
- Outstanding work has an owner
- Closure was explicitly recorded

Do not shorten or remove the assignment record when moving it here.

---

## Cancelled assignments

Cancelled assignments remain preserved with:

- Cancellation reason
- Who authorized cancellation
- Cancellation date
- Partial work produced
- Evidence retained
- Replacement assignment, if applicable

---

## Sequence registry

This section provides a quick reference for the last ID used.

Nova must still verify the full ledger before minting a new ID.

| Prefix | Last used | Next candidate |
|---|---:|---:|
| LAB-ABS-SEN | 001 | 002 |
| LAB-ABS-ARC | 001 | 002 |
| PH6-NOV | 000 | 001 |
| PH6-SHI | 000 | 001 |
| PH6-SEN | 001 | 002 |
| PH6-ARC | 001 | 002 |
| PH6-CLD | 001 | 002 |
| PH6-COD | 002 | 003 |
| PH1-ARC | 001 | 002 |
| PH1-SHI | 001 | 002 |
| PH1-CLD | 002 | 003 |

Update this table whenever a new assignment is created.

---

## Ledger maintenance

Nova should update this ledger when:

- An assignment is created
- Clarification is requested or resolved
- An assignment becomes ready to dispatch
- Dispatch occurs
- Work begins
- A blocker appears
- A handoff is received
- Evidence is validated
- Review begins or completes
- Remediation is required
- Approval is requested or received
- Work is completed
- Work is closed or cancelled

Nova must not update this ledger merely because an agent appears idle or stops responding.

---

## Evidence references

Preferred evidence references include:

- Repository-relative file paths
- Git commit SHA
- Pull request identifier
- Herdr session and agent reference
- Stored command transcript
- Validation record ID
- Security review ID
- ADR ID
- Evidence index ID

Do not place credentials, secrets, private keys, tokens, or sensitive raw evidence directly in this ledger.

---

## Initial status

Phase 6 orchestration standards are active.

Automatic Herdr transport is not yet validated.

Until automated dispatch is proven, the dispatch method must be recorded as one of:

- Manual relay
- Claude Code CLI
- Codex CLI
- Other explicitly disclosed fallback

No assignments have been created yet.
