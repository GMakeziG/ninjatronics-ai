# Zaifu Phase 1 — Wave 1 Tranche 1 Results and Tranche 2 Proposal

**Date:** 2026-08-23
**Status:** Tranche 1 complete and integrated; Tranche 2 not authorized or dispatched
**Orchestrator:** Pi acting in the Nova role

## 1. Dispatch and isolation

All three assignments ran as real Claude Code sessions through Herdr in separate Zaifu worktrees created from synthetic baseline `7798215c30bbe97722d68f8cd582fd7a62e1455a`. The synthetic baseline captured the approved, pre-existing dirty planning state without changing Zaifu `master` or its index.

| Assignment | Role/runtime | Worktree / branch | Herdr identity | Result commits | Fallback |
|---|---|---|---|---|---|
| PH1-ARC-001 | Archivist / Claude Code | `PH1-ARC-001` / `phase1/ph1-arc-001` | `ph1_arc_001`; `w1D:p1`; session `1833aa6d-c8b6-4826-9c6e-7ac01158bdf0` | `1979835` | Intentional, approved, conserved Hermes quota |
| PH1-CLD-002 | Forge / Claude Code | `PH1-CLD-002` / `phase1/ph1-cld-002` | `ph1_cld_002`; `w1E:p1`; session `72df30c4-01da-44c2-9bf4-cc7ef2ee8950` | `919b097`, `b81bf56` | Approved proposed runtime |
| PH1-SHI-001 | Shinobi / Claude Code | `PH1-SHI-001` / `phase1/ph1-shi-001` | `ph1_shi_001`; `w1F:p1`; session `e969c9d5-42b4-437e-bbeb-781be3ba63f6` | `73ac771`, `00185e2` | Approved; native Shinobi absent from validated dispatcher allow-list |

The initial 20-minute waits for PH1-ARC-001 and PH1-SHI-001 timed out while both agents remained live and working. The orchestrator inspected live state/transcripts and waited again; both completed. This transport event is preserved, not hidden, in each `transport.json`.

## 2. Independent validation results

### PH1-ARC-001 — passed with findings

- Clean assignment branch and bounded Zaifu documentation-only diff.
- Minor scope exception: the runtime also wrote `linkcheck.py` and `scopecheck.py` to the Ninjatronics handoff directory outside its worktree, then inaccurately attested that Ninjatronics was untouched. The benign evidence files are retained and the breach is recorded in validation.
- 94 relative Markdown links checked; 0 broken.
- 25 ADR headings for ADR-001 through ADR-025.
- Excluded financial engine/vector and LLM policy files unchanged.
- No cloud/resource/deployment/credential/DNS/spend action and no Codex use.
- Finding: package naming is not fully reconciled because two explicitly excluded/non-granted documents retain old package paths.
- Finding: worktree-only scope compliance was imperfect; future assignments should prohibit direct writes to the shared evidence directory and leave persistence to the orchestrator.
- Finding: security-document edits require PH1-SEN-002.
- Finding: WP-03/G2 must resolve the 70% trust ceiling versus answer threshold and confidence-band reachability.

Evidence: `shared/handoffs/PH1-ARC-001/{assignment.md,transport.json,result.md,validation.md}`.

### PH1-CLD-002 — passed with findings

Independent clean archive validation at `/tmp/ph1-cld-002-validation-1787529290`:

- `pnpm install --frozen-lockfile`: passed, 131 packages.
- `pnpm run validate`: passed.
- Format, root/package lint, and typecheck: passed.
- Tests: 5 files, 9/9 passed, 0 skipped.
- Independently parsed workspace graph: exact five names and acyclic.
- CI contains no secret reference, OIDC write permission, cloud, or deploy operation.
- Finding: no remote/host exists, so secret scanning, push protection, branch protection, and a real CI run cannot be enabled/evidenced. These were reported, not fabricated.

Evidence: `shared/handoffs/PH1-CLD-002/{assignment.md,transport.json,result.md,validation.md}`.

### PH1-SHI-001 — passed with findings

- Exact four-file boundary; clean branch and diff checks.
- Follow-up reconciled IC-01 through IC-10 against completed WP-01.
- No IaC or existing-file changes.
- No authenticated provider access, cloud CLI, resource, deployment, credential, DNS, spend, production, or destructive action.
- Public anonymous Azure Retail Prices endpoint use was disclosed and accepted as read-only documentation research.
- Official Microsoft/GitHub sources independently confirmed material creation-time, backup-deletion, networking, and Secret Protection findings.
- Finding: D-04/G5 must jointly decide region, residency, backup redundancy, key-management posture, and spend.
- Finding: frontend rendering model remains a residency checkpoint.
- Finding: design does not satisfy deployed restore/rollback criteria and does not claim to.

Evidence: `shared/handoffs/PH1-SHI-001/{assignment.md,transport.json,result.md,validation.md}`.

## 3. Integration order and commits

Zaifu `master` integration was completed in dependency order:

1. `7dabae2` — commit the pre-existing approved planning/dispatch baseline.
2. `ee41276` — integrate PH1-ARC-001 / WP-02.
3. `3315e65`, `2df8931` — integrate PH1-CLD-002 / WP-01.
4. `f530a7a`, `ae8d873` — integrate PH1-SHI-001 initial design and its post-WP-01 interface reconciliation.
5. `a243598` — ignore generated `graphify-out/` under the Ninjatronics generated-artifact policy.

No push, remote, deployment, or production action occurred.

## 4. Repository-wide validation

Run from integrated Zaifu `master`:

- `pnpm install --frozen-lockfile`: pass.
- `pnpm run validate`: pass.
- Format/lint/package-lint/typecheck: pass.
- Tests: 9/9 pass, 0 skipped.
- Markdown: 49 files, 94 relative links, 0 broken.
- `git diff --check`: pass.
- `graphify update .`: pass; 1,481 nodes, 1,489 edges, 97 communities. Generated output is ignored.
- Final `git status --short --branch`: clean `master`.

Known non-failing warning: pnpm 9.15.9 emits Node DEP0169 from pnpm's internal use of `url.parse()`.

## 5. Codex eligibility determination

**Codex remains eligible** for both independent roles proposed for Tranche 2:

- No Tranche 1 assignment used Codex.
- Codex implemented no repository, CI, security-document, Mode A policy, platform, or financial-value control.
- Every assignment and handoff explicitly records Codex non-use.
- A new Codex review session will be independent of the Claude-authored artifacts.

Eligibility is scope-specific and must be rechecked immediately before each dispatch. If Codex implements or modifies any reviewed control first, it becomes ineligible for that control.

## 6. Reassessment of undispatched assignments

### PH1-SEN-001 — recommended, first in Tranche 2

**Recommendation:** approve dispatch after this report.

- Dependency on integrated WP-02 is now satisfied.
- Use Claude Code carrying Sentinel rules, as previously approved, to author WP-11 Mode A policy/data contract.
- Strict design/documentation only: no provider call, no production-data egress, no Mode B enablement, no cloud/resource action.
- It must incorporate the reconciled 70% trust ceiling and preserve authoritative engine values without resolving WP-03 financial rules.
- It may not approve its own policy; PH1-SEN-002 remains required.

### PH1-SEN-002 — recommended, but only after PH1-SEN-001 returns

**Recommendation:** approve as a dependency-gated second step, not concurrent with PH1-SEN-001.

- Use Codex carrying Sentinel review rules.
- Codex is currently independent and eligible.
- Review the integrated PH1-ARC-001 security-document edits, PH1-CLD-002 repository/CI controls and explicit hosted-control gaps, PH1-SHI-001 platform design, and PH1-SEN-001 Mode A policy.
- Require control-by-control verdicts, severity, exact evidence, remediation/re-review conditions, and an explicit runtime-eligibility statement.
- This is not WP-15 and cannot approve release.

### PH1-COD-001 — recommended after PH1-SEN-001, parallel with PH1-SEN-002 if isolated

**Recommendation:** approve as a dependency-gated read-only Ledger review.

- Use Codex carrying Ledger rules.
- Verify value-fidelity invariants: deterministic explanations cannot alter authoritative values; provider abstraction is never a calculation source; future substitution requirements preserve exact numeric fidelity.
- The newly surfaced 70% ceiling/answer-threshold question is a WP-03/G2 issue and must not be silently decided by this review.
- This review does not close G2.

## 7. Proposed Tranche 2 dispatch sequence

If Gerso approves all three:

1. Dispatch PH1-SEN-001 alone in its own worktree.
2. Active orchestrator independently validates and integrates it.
3. Recheck Codex eligibility.
4. Dispatch PH1-SEN-002 and PH1-COD-001 as separate read-only assignments. They may run concurrently because they have distinct review scopes and no file modification authority.
5. Validate both handoffs and stop at any remediation or human gate.

Current runtime policy prohibits Hermes for WP-15 or any other execution. Preserve an untouched Claude Code or Codex runtime for high-value release security review; if neither remains eligible, stop and request Gerso's decision. No Tranche 2 assignment was created or dispatched by this proposal.

## 8. Open gates and retained risks

- G2 remains open; WP-03 financial baseline work is still required.
- G3/D-01, D-03, D-06, and G6/D-07 remain pending.
- G5 remains closed; no cloud resource/spend/deployment authorization exists.
- Hosted repository security controls remain unavailable until a host and any related spending decision exist.
- Two legacy package-path references require a bounded follow-up before baseline closure.
- The 70% ceiling versus answer threshold/band reachability is an explicit WP-03/G2 blocker, not resolved by Tranche 1.
