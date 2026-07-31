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

|| Assignment ID | Title | Owner | Priority | Status | Depends on | Reviewer | Approval required | Last updated |
||---|---|---|---|---|---|---|---|---|
|| LAB-ABS-SEN-001 | Independent security review of PR #6 (Audiobookshelf GitOps) | Sentinel (live Herdr dispatch) | High | Complete — Nova-validated (verdict PASS WITH NOTES; transport exit 0; identity verified) | None | Nova | None — evidence artifact retained | 2026-07-28 |
|| LAB-ABS-ARC-001 | Merge and cutover evidence checklist for Audiobookshelf PR #6 | Archivist (live Herdr dispatch) | High | Complete — Nova-validated (verdict Complete with findings; transport exit 0; identity verified; checklist + supporting doc evidence) | LAB-ABS-SEN-001 | Nova | None — evidence artifact retained | 2026-07-28 |
|| PH6-SEN-001 | Independent security review of feat/audiobookshelf | Sentinel (fallback: delegated subagent deleg_a47f68e5) | High | Reviewed — accepted by Nova (verdict PASS; evidence independently re-validated) | None | Sentinel | Gerso (merge gate) | 2026-07-28 |
|| PH6-COD-001 | Remediate Sentinel BLOCKER/HIGH findings on feat/audiobookshelf | Codex (fallback: delegated subagent) | High | Cancelled (no BLOCKER/HIGH findings) | PH6-SEN-001 | Sentinel (re-review) | Gerso (merge gate) | 2026-07-28 |
|| PH6-ARC-001 | Documentation for Audiobookshelf deployment | Archivist (fallback: delegated subagent deleg_1d2cb368) | Normal | Complete — accepted by Nova (commit 7cf3fc7; evidence validated) | PH6-SEN-001 | Nova | None | 2026-07-28 |
|| PH6-CLD-001 | Herdr v0.7.5 contract discovery for Nova→Herdr→specialist transport | Claude Code (runtime; deleg_1cd1fe0e) | High | Complete — accepted by Nova (contract proven end-to-end via live probe; evidence in transcript) | None | Nova | Gerso (plan approval before Phase 2) | 2026-07-28 |
|| PH6-COD-002 | Implement Nova→Herdr→specialist transport (dispatch-specialist.sh + libs + docs); optional `hermes -z` spike | Codex (runtime) | High | Complete — Nova-reviewed & live-validated (TEST A/B/C/D pass; Nova fixed 3 integration bugs: stderr error-parse, whole-line markers, teardown verify) | PH6-CLD-001 | Nova | Gerso (merge gate) | 2026-07-28 |

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

## Active assignments

Assignments remain in this section until they are Closed or Cancelled.

Copy the template below for each active assignment.

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

|| Prefix | Last used | Next candidate |
||---|---:|---:|
|| LAB-ABS-SEN | 001 | 002 |
|| LAB-ABS-ARC | 001 | 002 |
|| PH6-NOV | 000 | 001 |
|| PH6-SHI | 000 | 001 |
|| PH6-SEN | 001 | 002 |
|| PH6-ARC | 001 | 002 |
|| PH6-CLD | 001 | 002 |
|| PH6-COD | 002 | 003 |

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
