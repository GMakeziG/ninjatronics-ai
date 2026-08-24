# Orchestrator Validation — PH1-CLD-001

**Date:** 23-08-2026

**Reviewer:** Pi acting as active Ninjatronics orchestrator (Nova role)

**Disposition:** Accepted with corrections required in orchestration synthesis

## Deliverable validation

- Persisted result exists at `shared/handoffs/PH1-CLD-001/result.md`.
- Project-local copy exists at
  `/home/gerso/Development/zaifu/docs/orchestration/handoffs/PH1-CLD-001.md`.
- Both copies are byte-identical and contain 1,568 lines.
- The result defines 16 bounded packages, `PH1-WP-01` through `PH1-WP-16`.
- All 16 packages include dependencies, explicit out-of-scope boundaries,
  acceptance criteria, validation/evidence, owner/runtime, reviewer, and human
  gate fields.
- The result includes a dependency graph, routing matrix, Sentinel review
  matrix, LLM trust-boundary design, decision register, escalations, and a
  proposed first wave.
- Claude reported no implementation and no repository modification. Before and
  after Git status evidence confirms Claude did not add changes beyond the
  active orchestrator's pre-dispatch records.

## Independently verified findings

The active orchestrator verified against Zaifu source that:

1. `SECURITY_ARCHITECTURE.md:93,145` and `THREAT_MODEL.md:72,107` still describe
   consumer MFA as optional/open, conflicting with ADR-022.
2. `USER_JOURNEYS.md` J-04 is forecast review, not import, while the gate review
   claims J-04 documents import.
3. `PRODUCT_REQUIREMENTS.md:250` excludes document import while ADR-010 requires
   CSV/document import, creating a real scope conflict.
4. `FINANCIAL_TEST_VECTORS.md` contains contradictory output/derivation values
   for TV-03, TV-16, and TV-17 plus unresolved authoring text.
5. `FINANCIAL_ENGINE.md` specifies nearest-integer confidence rounding while
   the test vectors specify `floor`, and `assumption_trust` definitions differ.
6. Zaifu contains no application implementation files (`package.json`,
   `pnpm-workspace.yaml`, TypeScript, TSX, or Prisma schema) and no workflow
   implementation.

These findings justify baseline reconciliation and canonical financial-rule
work before engine implementation.

## Validation findings on the returned plan

### V-01 — WP-03 and WP-04 cannot run concurrently

The package definition says WP-04 depends on WP-03, but the safe-wave section
lists `{WP-03, WP-04}` together. Correct sequence:

`WP-03 -> WP-04 -> WP-05`.

Disjoint files do not remove a declared semantic dependency.

### V-02 — WP-11 cannot close in the same unrestricted wave as WP-02

WP-11 declares WP-02 as a dependency. WP-11 may begin read-only discovery in
parallel, but its policy baseline cannot be finalized until WP-02 closes.

### V-03 — WP-01 scaffolding is gated by package naming

WP-01 may perform design work in parallel, but it must not create workspace
package directories until DO-06/package naming is resolved and recorded through
WP-02.

### V-04 — “Critical path” is not proven without package durations

Claude deliberately omitted estimates. The listed path is accepted as the
**dependency spine**, not a measured critical path. Scheduling requires sizing
or observed durations later.

### V-05 — Gates G1 through G6 are referenced but not defined in one registry

The synthesis must define them explicitly before implementation assignments:

- G1: Gerso approves the Phase 1 plan and scope.
- G2: Gerso approves reconciled product/financial baseline decisions.
- G3: MFA method and recovery design approved before authentication work.
- G4: LLM trust-boundary policy and operating mode approved.
- G5: Cloud spend, region, residency, and resource creation approved.
- G6: Sentinel validation and release-readiness evidence accepted by Gerso.

### V-06 — Household-ready schema must not become Phase 1 functionality

The proposed nullable `household_id` in WP-04 is not required for MVP behavior
and risks ambiguity under ADR-025. The orchestrator recommends omitting
household/multi-user tables, routes, roles, invitations, and permissions from
Phase 1. Any future-ready column must be separately justified as inert schema
only and must not enable shared access.

## Routing validation

Accepted routing shape:

- Claude Code: broad design, cross-document reconciliation, schema/API/auth/Koban
  architecture, UX architecture, and infrastructure design.
- Codex: bounded implementation against approved designs and fixtures, focused
  tests, repetitive CRUD handlers, engines, instrumentation, and independent
  second review where appropriate.
- Sentinel: security-policy ownership where assigned and mandatory independent
  review of MFA, authorization, encryption, auditing, backup/restore,
  export/delete, provider handling, instrumentation privacy, and final release.
- Ledger/financial correctness: unresolved operational ownership because no real
  Ledger runtime exists. Engine implementation must not begin until a named
  independent financial reviewer is authorized.

## Final validation result

The handoff is accepted as a strong Phase 1 planning basis with the six
corrections above applied by the active orchestrator in the approval synthesis.
No implementation package is authorized or dispatched by this validation.
