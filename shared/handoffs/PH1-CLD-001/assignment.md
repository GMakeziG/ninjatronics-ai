# Assignment

## Assignment ID

`PH1-CLD-001`

## Owner

Claude Code

## Requested by

Pi acting as the active Ninjatronics orchestrator (Nova role)

## Priority

High

## Objective

Convert Zaifu's approved Phase 0 architecture, requirements, security
constraints, and owner decisions into a sequenced Phase 1 implementation plan
with bounded work packages, explicit dependencies, acceptance criteria,
validation requirements, evidence requirements, routing recommendations, and
approval gates.

## Context

Gerso approved the Phase 0 gate on 23-08-2026 and authorized Phase 1 planning.
The planning result will be reviewed by the active orchestrator and presented to
Gerso before any implementation assignment is dispatched.

Binding decisions:

1. MFA is required for the MVP as a baseline authentication control.
2. Production financial data must not cross an external LLM provider boundary
   by default. Phase 1 must define allowed data, redaction/minimization,
   retention/privacy requirements, provider access controls, and enforcement.
   Identifiable production financial data requires explicit future approval.
3. Sentinel owns independent pre-release security validation. Implementers may
   produce evidence but may not approve their own controls.
4. Household and multi-user functionality are out of Phase 1 scope unless
   explicitly authorized. Introduction requires a new authorization design and
   threat-model review.

Phase 0 historical ledger/handoff reconciliation is deferred and must not be
performed as part of this assignment.

## Scope

Read and analyze `/home/gerso/Development/zaifu`, especially:

- `README.md`
- `docs/planning/PHASE_0_GATE_REVIEW.md`
- `docs/planning/DECISION_LOG.md`
- `docs/planning/PRODUCT_REQUIREMENTS.md`
- `docs/planning/USER_JOURNEYS.md`
- `docs/planning/MVP_REFINED.md`
- `docs/planning/ASSUMPTIONS.md`
- `docs/planning/RISKS.md`
- `docs/product/PRODUCT_CHARTER.md`
- `docs/product/TRUST_MODEL.md`
- `docs/product/FINANCIAL_CONFIDENCE.md`
- `docs/product/EXPLAINABILITY.md`
- `docs/product/SUCCESS_METRICS.md`
- `docs/architecture/DOMAIN_MODEL.md`
- `docs/architecture/FINANCIAL_ENGINE.md`
- `docs/architecture/FINANCIAL_TEST_VECTORS.md`
- `docs/security/SECURITY_ARCHITECTURE.md`
- `docs/security/THREAT_MODEL.md`
- `docs/security/DATA_CLASSIFICATION.md`
- `docs/orchestration/AGENT_ROSTER.md`

Also read the Ninjatronics routing and orchestration standards needed to make
owner/runtime recommendations.

## Out of scope

- Application, infrastructure, schema, configuration, or test implementation
- Modifying any file in Zaifu or Ninjatronics
- Dispatching follow-up agents
- Selecting an LLM provider
- Authorizing identifiable production financial data for external processing
- Household or multi-user design or implementation
- Historical Phase 0 orchestration reconciliation
- Production deployment or release approval

## Inputs

- Phase 0 gate approval and decisions recorded in:
  - `docs/planning/PHASE_0_GATE_REVIEW.md`
  - `docs/planning/DECISION_LOG.md` ADR-022 through ADR-025
- Ninjatronics standards:
  - `/home/gerso/Development/ninjatronics-ai/shared/standards/agent-routing.md`
  - `/home/gerso/Development/ninjatronics-ai/shared/standards/orchestration.md`
  - `/home/gerso/Development/ninjatronics-ai/shared/standards/collaboration-workflow.md`
  - `/home/gerso/Development/ninjatronics-ai/shared/standards/security-review.md`

## Graphify context

- Zaifu has no `graphify-out/graph.json`.
- Graphify is therefore unavailable for the target repository.
- Use direct source inspection and explicitly identify contradictions or stale
  documents that materially affect the plan.

## Constraints

- Strictly read-only: do not modify any file or repository state.
- Do not implement application code.
- Do not install packages or dependencies.
- Do not create branches, worktrees, commits, or pull requests.
- Verify conclusions against source files and cite paths/sections.
- Treat the four owner decisions as binding constraints.
- Preserve the refined MVP boundary: checking balance, recurring income,
  recurring obligations, and the "$500 purchase question"; no credit cards,
  household access, bank aggregation, investments, taxes, budgeting, or
  autonomous money movement unless authoritative newer source explicitly says
  otherwise.

## Required deliverables

Return one structured Phase 1 planning handoff containing:

1. **Executive summary** and planning assumptions.
2. **Authoritative baseline** and any source contradictions that must be
   resolved before or during implementation.
3. **Sequenced work packages**, each with:
   - Stable proposed package ID (`PH1-WP-XX`)
   - Objective and bounded scope
   - Explicit out-of-scope items
   - Likely files/modules to be created or changed
   - Dependencies and prerequisites
   - Acceptance criteria
   - Validation and evidence requirements
   - Recommended domain owner and execution runtime
   - Required reviewer, including Sentinel where applicable
   - Human approval gates
4. **Dependency graph and critical path**, with safe parallelization boundaries
   and non-overlapping file ownership guidance.
5. **Claude Code versus Codex routing recommendation** for every package.
6. **Security review matrix** mapping MFA, authorization, encryption, auditing,
   backup/restore, export/delete, and provider handling to implementation
   packages, evidence producers, and Sentinel review points.
7. **LLM trust-boundary plan** defining the Phase 1 design work needed for data
   allowlisting, minimization/redaction, retention/privacy requirements,
   provider access control, logging, and deny-by-default enforcement without
   selecting a provider or authorizing identifiable data.
8. **Decision register** listing any additional decisions required from Gerso,
   when each decision is needed, and which work it blocks.
9. **Recommended first implementation wave**, but do not dispatch or implement
   it.

## Validation required

- Confirm both Zaifu and Ninjatronics working trees were not modified.
- Check every proposed work package has dependencies, acceptance criteria,
  validation, evidence, owner/runtime, review, and scope boundaries.
- Confirm the dependency graph has no unexplained cycles.
- Confirm all four binding owner decisions are represented.
- Confirm no Phase 1 package includes household/multi-user functionality.
- Confirm no package assumes external LLM access to production financial data.
- Confirm implementation is not performed.

## Evidence required

- Paths and sections examined
- Commands used for read-only inspection
- Git status before and after analysis
- Traceability from each work package to Phase 0 requirements, ADRs, security
  controls, or test vectors
- Explicit statement that no files were modified

## Dependencies

- Gerso Phase 0 gate approval: satisfied on 23-08-2026
- ADR-022 through ADR-025: recorded
- No implementation dependency

## Escalation conditions

Escalate rather than assume if:

- Authoritative sources conflict in a way that changes the MVP boundary,
  architecture, security baseline, or package sequence.
- A required plan depends on selecting a provider or permitting identifiable
  production financial data.
- A package would require household/multi-user scope.
- Financial correctness ownership or independent security review cannot be
  assigned under the current roster.
- A material architecture choice lacks enough evidence for a bounded plan.

## Completion criteria

- All required deliverables are returned in one structured handoff.
- The plan is implementation-ready but contains no implementation.
- Work packages are bounded, sequenced, traceable, independently reviewable,
  and routable to Claude Code or Codex.
- Security evidence and Sentinel review gates are explicit.
- Remaining human decisions are clearly identified.

## Recommended next owner

Active orchestrator for validation and synthesis, then Gerso for Phase 1 plan
approval before implementation dispatch.
