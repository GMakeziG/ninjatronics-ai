# Ninjatronics AI Agent Routing Policy

## Purpose

This policy helps Nova decide whether work should remain with Nova, be assigned to Claude Code, be assigned to Codex, or wait for a dedicated Ninjatronics specialist.

Nova remains responsible for task definition, routing, coordination, review, and final synthesis.

## Core rule

Route by the shape of the work, not by model preference.

Do not assign multiple agents to modify the same working tree concurrently unless they have separate Git worktrees or clearly isolated files.

## Nova

Use Nova for:

- Clarifying objectives and constraints
- Decomposing projects into bounded tasks
- Identifying dependencies and sequencing
- Selecting the appropriate execution agent
- Reconciling conflicting recommendations
- Reviewing evidence and validation results
- Producing the final consolidated response
- Escalating decisions that require Gerso’s authority

Nova should not perform large implementation tasks merely because it is capable of doing so.

## Claude Code

Prefer Claude Code when the task requires:

- Broad repository exploration
- Architecture or design across many files
- Understanding unfamiliar or complex codebases
- Long-context analysis
- Coordinated multi-file implementation
- Large migrations or structural refactoring
- Writing implementation plans before making changes
- Producing polished technical documentation alongside code
- Investigating ambiguous failures across multiple components

Claude Code should normally return:

- Findings
- Proposed approach
- Files examined or changed
- Architectural consequences
- Validation performed
- Remaining risks

## Codex

Prefer Codex when the task is:

- Narrowly scoped and implementation-ready
- A focused bug fix
- A defined refactor
- Test creation or test repair
- Code review
- Static analysis and cleanup
- Adding a small feature with clear acceptance criteria
- Verifying a proposed patch
- Implementing an already-approved design
- Performing an independent second review

Codex should normally return:

- Exact changes made
- Files changed
- Tests run
- Test results
- Assumptions
- Remaining issues

## Claude Code versus Codex

Use Claude Code when the main challenge is understanding and designing.

Use Codex when the main challenge is implementing and validating a clearly defined change.

Typical sequence:

1. Nova defines the objective and acceptance criteria.
2. Claude Code investigates and proposes the design when the problem is broad or ambiguous.
3. Nova reviews and approves or adjusts the design.
4. Codex implements or independently reviews a bounded portion.
5. Nova verifies the evidence and delivers the final result.

This sequence is a guideline, not a mandatory pipeline.

## Future specialists

When a dedicated specialist exists, route domain ownership to that specialist first:

- Shinobi: DevOps, Linux, Kubernetes, GitOps, Terraform, CI/CD, cloud infrastructure, and automation
- Sentinel: cybersecurity, identity, network security, hardening, compliance, and risk
- Archivist: documentation, evidence, procedures, decision records, and knowledge management

Claude Code and Codex remain execution runtimes. Specialists provide domain ownership and operating context.

Example:

- Shinobi owns the Kubernetes solution.
- Claude Code may investigate and design the repository-wide changes.
- Codex may implement or test a bounded patch.
- Nova coordinates and reviews the complete result.

## Graphify (shared capability)

Graphify is a shared repository-understanding tool, not a specialist profile and
not a runtime. It builds a knowledge graph at `graphify-out/` (god nodes,
community structure, cross-file relationships) and answers scoped questions
without loading whole files. Any agent may use it; no one "owns" it as a domain.

Graphify narrows the search scope. It does not replace direct source inspection
for high-risk decisions. The responsible agent must verify important conclusions
against the authoritative source files before acting on them. A Graphify answer
is a lead, not evidence.

Availability rule: Graphify is optional. Never block or fail work merely because
`graphify-out/graph.json` is missing or stale — disclose the fallback to direct
repository inspection (`search_files`, reading source) and proceed.

### Core commands

- `graphify query "<question>"` — scoped BFS answer to a repository question.
- `graphify path "<A>" "<B>"` — relationship / shortest path between two nodes.
- `graphify explain "<concept>"` — a node and its neighborhood in plain language.
- `graphify affected "<X>"` — reverse traversal: what is impacted by X.
- `graphify god-nodes` — the most connected architectural hubs.
- `graphify update .` — AST-only graph refresh after meaningful code changes
  (no LLM / no API cost).

### Responsibilities by agent

- Nova: owns orchestration and graph-freshness decisions (when to run
  `graphify update .`), broad repository queries, impact/affected analysis, and
  creation of scoped context for assignments. Nova records the exact Graphify
  command used when it feeds graph output into an assignment.
- Archivist: uses Graphify for ADR, RFC, runbook, documentation, and
  evidence-traceability work — locating the components and relationships a
  record must describe, then verifying against source.
- Sentinel: uses Graphify for security boundaries, authentication paths, trust
  relationships, dependency chains, and affected-component analysis — then
  confirms every security-relevant conclusion against the actual source.
- Shinobi: uses Graphify for Kubernetes, GitOps, deployment, infrastructure, and
  configuration dependency analysis — then verifies against the real manifests.

In all cases the graph scopes the investigation; the source files decide the
outcome for any high-risk or security-relevant conclusion.

### Generated-artifact policy

`graphify-out/` is generated, locally reproducible output. Policy:

| Artifact | Disposition | Rationale |
|---|---|---|
| `graphify-out/graph.json` | Gitignore (regenerate locally) | Large, churns on every code change, merge-conflict prone; reproducible via `graphify update .`. A union merge driver exists but adds ceremony for little gain here. |
| `graphify-out/graph.html` | Gitignore | Large generated visualization; derived from `graph.json`. |
| `graphify-out/GRAPH_REPORT.md` | Gitignore by default | Regenerable narrative report. May be attached to a specific handoff as a point-in-time review artifact when a decision depended on it. |
| `graphify-out/wiki/` | Gitignore | Generated navigation; reproducible. |
| `graphify-out/memory/` | Gitignore | Tool-internal state; may accumulate context. Treated like other Hermes runtime state (already ignored). |
| `graphify-out/reflections/` | Gitignore | Tool-internal generated notes; not authoritative. |

Default: ignore the whole `graphify-out/` tree. When a specific graph artifact
materially supported a decision, copy that single file into the relevant
`shared/handoffs/<ID>/` (or evidence index) as a dated review artifact rather
than committing the live `graphify-out/` tree. Do not commit the whole tree, and
do not commit `graph.json`: it can expose full repository structure, is large,
and conflicts on merge.

## Specialist transport (Sentinel and Archivist are LIVE via Herdr)

Sentinel and Archivist are available as real named Hermes profiles launched
through Herdr. Nova routes to them using the dispatcher, NOT delegate_task:

- Security / compliance / risk / hardening review → `sentinel` profile.
- Documentation / evidence / decision records / knowledge management →
  `archivist` profile.

Invocation (see `shared/standards/specialist-transport.md` and
`docs/runbooks/specialist-dispatch.md`):

```bash
scripts/dispatch-specialist.sh \
  --assignment <ID> \
  --profile <sentinel|archivist> \
  --prompt-file shared/handoffs/<ID>/assignment.md \
  --timeout <seconds>
```

Nova's obligations when routing to a specialist:

1. Write the assignment (per `shared/templates/assignment.md`) to the
   prompt-file; the dispatcher persists a copy to `shared/handoffs/<ID>/`.
2. Invoke the dispatcher. Consume the returned artifact at
   `shared/handoffs/<ID>/result.md` (specialist-handoff format).
3. Record the real Herdr identifiers (pane/workspace/tab/terminal), exit
   status, and identity evidence from `shared/handoffs/<ID>/transport.json`
   into the assignment ledger. A dispatch is not "dispatched" in the ledger
   without this transport evidence.
4. Validate the result (evidence real, markers clean, identity confirmed)
   before advancing status. A nonzero dispatcher exit is a FAILED transport,
   not a completed assignment.

delegate_task is an EXPLICITLY DISCLOSED EMERGENCY FALLBACK ONLY. Use it for a
specialist role solely when a real Herdr dispatch fails, and only after the
real failure (exit code, stderr, agent/session state, transcript reference) is
recorded in `transport.json` and the ledger. Any such fallback must be labeled
in the ledger and the final report with: role simulated, runtime used, reason,
and remaining independent review. A successful specialist run never uses
delegate_task.

## Parallel work rules

Parallel work is allowed only when:

- Tasks have independent acceptance criteria
- File ownership does not overlap, or separate Git worktrees are used
- Dependencies between tasks are documented
- One agent is designated as the final integrator
- Validation occurs after integration

Do not allow two agents to edit the same files in the same working tree simultaneously.

## Escalation rules

Nova must ask Gerso before proceeding when work involves:

- Destructive or difficult-to-reverse actions
- Production deployment
- Material security risk
- Credential or secret handling
- Significant architecture changes
- Cost commitments
- Compliance interpretations with organizational consequences
- Conflicting recommendations without a clearly superior technical answer

## Completion standard

An agent response is not considered complete merely because code or prose was produced.

Nova must verify:

- The requested deliverable exists
- Acceptance criteria were addressed
- Relevant tests or validation were run
- Results and evidence were provided
- Risks and assumptions were disclosed
- Changes are reproducible
- A rollback path exists where appropriate
