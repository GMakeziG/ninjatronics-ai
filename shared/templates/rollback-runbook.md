# Rollback Runbook: System / Service Name

- Runbook ID: RB-ROLLBACK-NNNN
- Version: 1.0
- Last updated: YYYY-MM-DD
- Owner:
- Executor:
- Pairs with: deployment runbook link

## Purpose

What this runbook reverts and the state it restores.

## Target restore state

Be exact: version, tag, configuration snapshot, database state.
"Previous version" is not a target; "v1.2.2, config commit abc1234,
DB snapshot 2026-07-27T02:00Z" is.

## Decision authority

Who may order a rollback, and who must be notified when it starts.

## Trigger criteria

Rollback is executed when any of:

- Condition 1 (with the metric/observation that proves it)
- Condition 2

## Preconditions

- [ ] Restore artifacts exist and are verified (backup, snapshot, prior image)
- [ ] Required access confirmed
- [ ] Data-loss window understood and accepted (state it explicitly)
- [ ] Stakeholders notified rollback is starting

## Data considerations

- Data written since deployment: preserved / lost / migrated — state which
- Irreversible steps in the original deployment (schema migrations,
  key rotations, deleted resources) and how each is handled

## Procedure

### Step 1 — Name

Command:

    exact command here

Expected result:

Evidence to capture:

If it fails: next action (alternate path, escalate to whom).

### Step 2 — Name

(Repeat for every step.)

## Validation

Proof the system is back to the target restore state.

- [ ] Version check:
- [ ] Health check:
- [ ] Functional smoke test:
- [ ] Data integrity check:
- [ ] Security posture unchanged:

## If rollback fails

Escalation path, break-glass contacts, and the last-resort recovery
option (e.g., full restore from backup with stated RTO/RPO).

## Post-rollback

- [ ] Evidence filed in evidence index
- [ ] Incident/lessons-learned record opened
- [ ] Root cause investigation assigned (owner)
- [ ] Release notes / status updated

## Tested

Rollback procedures that have never been exercised are assumptions.

| Date | Environment | Result | Evidence |
|------|-------------|--------|----------|

## Change history

| Date | Version | Change | Author |
|------|---------|--------|--------|
