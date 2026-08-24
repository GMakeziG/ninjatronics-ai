# PH1-SEN-002 Findings Summary

**Date:** 2026-08-23  
**Validated disposition:** Remediation required; no BLOCKER; three HIGH findings, one MEDIUM, one LOW.

## HIGH

1. **CI branch mismatch:** `.github/workflows/ci.yml` triggers only for `main`, while integrated Zaifu uses `master`; proposed branch-protection instructions also name `main`. Align the authoritative default branch, workflow triggers, and future required check, then obtain hosted-run evidence.
2. **Hosted repository controls absent:** no remote/host exists, so secret scanning, push protection, branch protection, workflow-change protection, and hosted CI evidence do not exist. This was accurately disclosed. Remediation depends on repository-host and any cost/visibility decisions.
3. **Network-layer provider allowlist incomplete:** the platform design proposes an NSG `FQDN or IP-scoped rule` without selecting a supported DNS/FQDN-aware enforcement mechanism or requiring stable dedicated provider addresses. Select an enforceable fail-closed pattern and reconcile cost/residency effects before WP-14 implementation approval.

## MEDIUM

- **Dependency lifecycle scripts:** frozen lockfile install does not explicitly disable, allowlist, inventory, or audit dependency install scripts. Define and enforce a policy before privileged CI capabilities or credentials are introduced.

## LOW

- **Schema cross-field invariants:** JSON Schema closure is sound, but token membership/subset relationships require explicit broker enforcement and later negative/property tests.

## Scope effects

- This review is not WP-15 and grants no release approval.
- Mode B, cloud resources, deployment, spending, production-data egress, and G2 remain unauthorized/open.
- Re-review is required after remediation or any material change to the reviewed controls.

Full evidence: `result.md`. Independent validation: `validation.md`.
