# Deployment Runbook: System / Service Name

- Runbook ID: RB-DEPLOY-NNNN
- Version: 1.0
- Last updated: YYYY-MM-DD
- Owner: role or specialist responsible for maintaining this runbook
- Executor: role permitted to run it
- Related: ADR links, rollback runbook link, SSP control references

## Purpose

What this runbook deploys and why it exists.

## Scope

- System(s):
- Environment(s):
- Repositories and branches:
- Out of scope:

## Preconditions

All must be true before starting. Verify, do not assume.

- [ ] Required approvals obtained (list who)
- [ ] Change window confirmed
- [ ] Backup or snapshot taken and verified restorable
- [ ] Rollback runbook reviewed and viable (link)
- [ ] Required access confirmed (list accounts/roles, least privilege)
- [ ] Dependencies healthy (list checks and expected output)
- [ ] Stakeholders notified

## Inputs

Variables and values needed for this run.

| Variable | Description | Source | Example |
|----------|-------------|--------|---------|
| VERSION  | Release tag | Git    | v1.2.3  |

## Procedure

Each step: exact command, expected result, evidence to capture.

### Step 1 — Name

Command:

    exact command here

Expected result:

    what success looks like, verbatim where possible

Evidence: what to capture (output, screenshot, log excerpt) and where
to store it (evidence index reference).

If it fails: stop / retry / rollback — state which.

### Step 2 — Name

(Repeat pattern for every step.)

## Validation

Checks that prove the deployment succeeded. Each with command and
expected output.

- [ ] Service health check:
- [ ] Functional smoke test:
- [ ] Logging operational:
- [ ] Monitoring/alerting shows expected state:
- [ ] Security controls intact (Sentinel criteria):

## Rollback trigger criteria

Deploy is aborted and rollback runbook executed when any of:

- Condition 1
- Condition 2

Rollback runbook: link. Decision authority: who may call it.

## Post-deployment

- [ ] Evidence filed in evidence index
- [ ] Validation record completed
- [ ] Release notes updated
- [ ] Stakeholders notified of completion
- [ ] Outstanding issues logged with owners

## Known pitfalls

Failure modes seen in past runs and how to avoid them.

## Change history

| Date | Version | Change | Author |
|------|---------|--------|--------|
