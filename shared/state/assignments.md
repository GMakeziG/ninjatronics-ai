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
