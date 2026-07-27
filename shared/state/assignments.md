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
13. Nova may propose ledger changes, but must not fabricate status, evidence, review, or approval.
14. Production, security, compliance, credential, financial, destructive, and irreversible work requires Gerso approval where defined by the orchestration standard.

---

## Assignment ID format

Use:

```text
<project-or-phase>-<owner-code>-<sequence>
Examples:

PH6-NOV-001
PH6-SHI-001
PH6-SEN-001
PH6-ARC-001
PH6-CLD-001
PH6-COD-001

Owner codes:

Code	Owner
NOV	Nova
SHI	Shinobi
SEN	Sentinel
ARC	Archivist
CLD	Claude Code
COD	Codex

Sequence numbers are tracked independently per project or phase and owner code.

Before minting an ID, Nova must search this file for the highest existing sequence for that prefix and increment it by one.

Example:

Highest existing ID: PH6-SHI-004
Next valid ID:       PH6-SHI-005
Allowed assignment states

Use only these states:

State	Meaning
Draft	Assignment is being written
Awaiting clarification	Material information is missing
Ready to dispatch	Assignment is complete and dependencies are satisfied
Dispatched	Assignment was sent to the owner
In progress	Owner has acknowledged or begun work
Blocked	Work cannot proceed
Awaiting review	Specialist handoff was received and review is required
Remediation required	Reviewer returned findings requiring changes
Awaiting approval	Required technical or human approval is pending
Complete	Assigned deliverables and validation were returned
Closed	All review, evidence, approvals, and documentation are complete
Cancelled	Work was intentionally stopped

The following states are not interchangeable:

Complete != Reviewed != Approved != Closed
Priority values

Use only:

Low
Normal
High
Urgent

Priority does not override approval gates or safety requirements.

Assignment summary

This table provides the current state of all assignments.

Assignment ID	Title	Owner	Priority	Status	Depends on	Reviewer	Approval required	Last updated
—	No assignments recorded yet	—	—	—	—	—	—	—

When the first real assignment is added, remove the placeholder row.

Active assignments

Assignments remain in this section until they are Closed or Cancelled.

<ASSIGNMENT-ID> — <Short title>
Metadata
Field	Value
Assignment ID	<ASSIGNMENT-ID>
Owner	<Nova / Shinobi / Sentinel / Archivist / Claude Code / Codex>
Requested by	Nova
Priority	<Low / Normal / High / Urgent>
Status	<Allowed state>
Created	<YYYY-MM-DD>
Last updated	<YYYY-MM-DD>
Reviewer	<Owner or Not assigned>
Approval required	<Gerso / Sentinel / Nova / None>
Recommended next owner	<Owner>
Objective

<Exact outcome expected>

Scope
<Included repository, files, systems, environment, or data>
Out of scope
<Explicit exclusions>
Inputs
<Required documents, paths, decisions, logs, or prior handoffs>
Constraints
<Read-only, no file modifications, no production changes, etc.>
Required deliverables
<Deliverable>
Validation required
<Test, review, or verification requirement>
Evidence required
<Command output, file path, diff, commit, log, screenshot, report, etc.>
Dependencies
<Assignment ID, approval, or external prerequisite>
None when no dependency exists.
Escalation conditions
<Condition requiring Nova or Gerso>
Completion criteria
<Condition that must be true before Complete status>
Status history
Date	Previous state	New state	Changed by	Reason	Evidence
<YYYY-MM-DD>	—	Draft	Nova	Assignment created	<Path or reference>
Dispatch record
Field	Value
Dispatch method	<Manual relay / Herdr / Claude Code CLI / Codex CLI / Other>
Dispatched to	<Agent/profile/runtime>
Dispatched by	<Nova / Gerso>
Date	<YYYY-MM-DD or Not dispatched>
Transport evidence	<Herdr handle, session/pane reference, transcript path, or Not dispatched>
Specialist handoff
Field	Value
Handoff received	<Yes / No>
Handoff path or reference	<Path or reference>
Reported status	<Status from specialist>
Evidence validated by	<Owner or Not yet validated>
Evidence validation result	<Accepted / Rejected / Partial / Pending>
Review record
Field	Value
Reviewer	<Sentinel / Claude Code / Codex / Nova / Other>
Review status	<Not started / In progress / Passed / Passed with findings / Failed>
Review artifact	<Path or reference>
High findings open	<Number>
Moderate findings open	<Number>
Remediation assignment	<Assignment ID or None>
Approval record
Field	Value
Approval required	<Yes / No>
Approver	<Gerso / Sentinel / Nova / Other>
Decision	<Pending / Approved / Rejected / Approved with conditions>
Date	<YYYY-MM-DD or Pending>
Approval evidence	<Reference>
Risks and outstanding work
<Known risk, deferred item, or unresolved question>
Closure record
Field	Value
Closure status	<Open / Closed / Cancelled>
Closed by	<Nova / Gerso>
Closure date	<YYYY-MM-DD or Open>
Final synthesis	<Path or reference>
Evidence index	<Path or reference>
Residual risk	<Summary or None>
Closed assignments

Move an assignment from Active assignments to this section only after:

Deliverables were returned
Validation was completed
Required review was completed
Findings were resolved or formally accepted
Evidence was indexed
Required approval was recorded
Nova issued final synthesis
Outstanding work has an owner
Closure was explicitly recorded

Do not shorten or remove the assignment record when moving it here.

Cancelled assignments

Cancelled assignments remain preserved with:

Cancellation reason
Who authorized cancellation
Date
Partial work produced
Evidence retained
Replacement assignment, if applicable
Sequence registry

This section provides a quick reference for the last ID used.

Nova must still verify the full ledger before minting a new ID.

Prefix	Last used	Next candidate
PH6-NOV	000	001
PH6-SHI	000	001
PH6-SEN	000	001
PH6-ARC	000	001
PH6-CLD	000	001
PH6-COD	000	001

Update this table whenever a new assignment is created.

Ledger maintenance

Nova should update this ledger when:

An assignment is created
Clarification is requested or resolved
An assignment becomes ready to dispatch
Dispatch occurs
Work begins
A blocker appears
A handoff is received
Evidence is validated
Review begins or completes
Remediation is required
Approval is requested or received
Work is completed
Work is closed or cancelled

Nova must not update this ledger merely because an agent appears idle or stops responding.

Evidence references

Preferred evidence references include:

Repository-relative file paths
Git commit SHA
Pull request URL or identifier
Herdr session and agent reference
Stored command transcript
Validation record ID
Security review ID
ADR ID
Evidence index ID

Do not place credentials, secrets, private keys, tokens, or sensitive raw evidence directly in this ledger.

Initial status

Phase 6 orchestration standards are active.

Automatic Herdr transport is not yet validated.

Until automated dispatch is proven, the dispatch method must be recorded as one of:

Manual relay
Claude Code CLI
Codex CLI
Other explicitly disclosed fallback

No assignments have been created yet.
