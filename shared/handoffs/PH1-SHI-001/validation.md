# Orchestrator Validation — PH1-SHI-001

**Date:** 2026-08-23
**Reviewer:** Pi acting as active orchestrator (Nova role)
**Disposition:** Passed with findings; integrated

## Identity, transport, and fallback

Real Claude Code runtime dispatched through Herdr as `ph1_shi_001` in isolated worktree `/home/gerso/Development/worktrees/zaifu/PH1-SHI-001`, carrying Shinobi rules under the approved fallback. Native Shinobi is not in the validated specialist dispatcher allow-list. The initial Herdr wait timeout, recovery, and bounded WP-01 interface follow-up are recorded in `transport.json`. Codex was not used.

## Scope and prohibited-action validation

- Exact four-file boundary passed: two platform documents and two assignment-specific orchestration documents only.
- Branch clean after commits `73ac771` and `00185e2`; `git diff --check` passed.
- Follow-up checked IC-01 through IC-10 against completed PH1-CLD-002 without modifying its worktree.
- Git evidence and Herdr transcript show design/public-research activity only. No IaC, cloud CLI/auth, authenticated console, resource creation, deployment, credential, DNS, spend, production, or destructive action occurred.
- The anonymous read-only Azure Retail Prices endpoint was used and disclosed. It is public pricing documentation, not a management-plane/resource action, and is accepted for this design assignment.

## Independent source checks

Official sources directly support material design findings:

- Microsoft PostgreSQL backup documentation: geo-redundant backup is selectable only at server creation; after provisioning backup redundancy cannot be changed; deleting a server deletes its associated backups and they cannot be recovered.
- Microsoft PostgreSQL encryption documentation: SMK versus CMK mode is selectable only at server creation and cannot change for the server lifetime.
- Microsoft Container Apps networking documentation: workload-profile environments support UDR and NAT Gateway egress; legacy consumption-only environments do not.
- GitHub documentation: Secret Protection covers secret scanning/push protection; private-repository billing is based on active committers, with the estimator showing a per-committer rate such as $19. Pricing remains an estimate to reconfirm at decision time.

## Findings

1. D-04/G5 must jointly decide region, residency, backup redundancy, CMK/SMK posture, and spend because several choices are creation-time constraints.
2. Secret Protection for a private hosted repository may add per-active-committer cost; G5/host decisions must not assume it is free.
3. Frontend rendering model remains a residency checkpoint. WP-01's current client/API separation supports but does not decide the no-Restricted-data-on-Vercel pattern.
4. This is design only. No WP-14 deployment/restore/rollback acceptance criterion is satisfied by prose.
5. PH1-SEN-002 must independently review architecture controls; Shinobi/Claude does not approve its own security posture.

## Integration

Initial design integrated as `f530a7a`; WP-01 interface reconciliation integrated as `ae8d873`, after WP-01 as required.

## Verdict

Accepted and integrated as decision-support design. G5 remains closed and no resource/spend authorization is inferred.
