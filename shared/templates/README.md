# Ninjatronics AI Document Templates

Reusable templates for the artifacts Archivist produces under the
collaboration workflow (shared/standards/collaboration-workflow.md).

| Template | File | When to use |
|----------|------|-------------|
| ADR | adr.md | Any architectural or significant technical decision |
| Deployment runbook | deployment-runbook.md | Repeatable deployment of a system or release |
| Rollback runbook | rollback-runbook.md | Paired with every deployment runbook |
| Evidence index | evidence-index.md | Per project, release, or audit period |
| Validation record | validation-record.md | Proving acceptance criteria were met |
| Release notes | release-notes.md | Every tagged release |
| Lessons learned | lessons-learned.md | After projects, incidents, and notable releases |

## Conventions

- IDs are sequential per type: ADR-0001, RB-DEPLOY-0001, RB-ROLLBACK-0001,
  EV-0001, VAL-0001, LL-0001.
- Copy the template; never edit templates to record a specific instance.
- Filled-in records live with the project or system they document, not here.
- A claim without indexed evidence is an assumption. Do not mark
  validation checks PASS without an evidence reference.
- Rollback runbooks that have never been tested must say so in their
  "Tested" table.
