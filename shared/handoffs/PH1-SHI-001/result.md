# Handoff: PH1-SHI-001 — WP-14 Platform Architecture and Cost/Residency Proposal

**Assignment:** `PH1-SHI-001` (project-local copy at `docs/orchestration/assignments/PH1-SHI-001.md`)
**Work package:** `PH1-WP-14` — Platform: infrastructure, secrets, encryption, backup and restore
**Specialist role:** Shinobi — infrastructure, operations, rollback, evidence, and security-review discipline
**Runtime:** **Claude Code carrying Shinobi rules as the approved fallback.** Native Shinobi is not in the validated specialist dispatcher allow-list. The fallback is disclosed here as the routing reassessment requires; no native runtime failure preceded it.
**Requested by:** Pi acting as active orchestrator (Nova role)
**Completed:** 2026-08-23
**Mode:** **Design and documentation only**, in the isolated worktree `PH1-SHI-001` on branch `phase1/ph1-shi-001`
**Revision:** initial delivery commit `73ac771`; **interface reconciliation follow-up** against `PH1-CLD-002` recorded in §4A
**Recommended next owner:** Active orchestrator for independent validation and interface reconciliation → `PH1-SEN-002` for architecture security review when authorized → Gerso for the later G5 / D-04 decision

---

## 1. Disposition

Complete within the assigned boundary. Four new files created, nothing else
touched. **G5 is preserved: no cloud resource, deployment, credential, DNS
change, or spend occurred.**

Delivered in two commits on the assignment branch: the initial design delivery,
and a follow-up that performs the assignment-required interface reconciliation
against `PH1-CLD-002` now that it has completed (§4A). The follow-up modified
only the same four owned files.

Two deliverables carry findings that the orchestrator should read before
integrating anything downstream — §5 items F-01 and F-02 change *when* decisions
must be made, not merely what they are.

---

## 2. Work performed

### 2.1 Deliverables

| File | Lines | What it is |
|---|---|---|
| `docs/platform/PHASE_1_PLATFORM_ARCHITECTURE.md` | 1,336 | The WP-14 design-only platform architecture: environment and trust boundaries, Azure/Vercel topology, the frontend data-path decision, GitHub Actions OIDC and managed-secret design, encryption and key separation, network exposure and egress, backup/restore/RPO/RTO, rollback and recovery, observability and auditability, supply chain, environment separation, a 17-row control matrix, ten residual risks, a three-stage post-G5 validation plan, twelve WP-01 integration checkpoints, and nine open owner/Sentinel decisions. Three Mermaid diagrams (trust boundaries, topology, deploy sequence). §13 now carries the completed `PH1-CLD-002` interface reconciliation. |
| `docs/platform/PHASE_1_COST_RESIDENCY_PROPOSAL.md` | 792 | Three costed region options with a full unit-price table dated 2026-08-23, three control profiles per option, line-by-line arithmetic shown as formulas, sensitivity analysis, a residency analysis covering all three processors, decision criteria, a recommendation subject to G5, and twelve labelled uncertainties. §9.5 records that the interface reconciliation changed no figure. |
| `docs/orchestration/assignments/PH1-SHI-001.md` | 111 | Byte-identical project-local copy of the issued assignment, matching the convention set by `PH1-CLD-001`. |
| `docs/orchestration/handoffs/PH1-SHI-001.md` | — | This handoff. |

No other file in Zaifu or Ninjatronics was created, modified, or deleted.

### 2.2 What the design actually settles

- **Topology.** Vercel frontend, Azure Container Apps API in a **workload-profiles**
  environment with a custom VNet, PostgreSQL Flexible Server on private access,
  Container Registry, two Key Vaults, Log Analytics, and an immutable evidence
  container — across **two Azure subscriptions** (production and non-production)
  in one Entra tenant.
- **No cloud credential exists anywhere.** OIDC federated identity credentials
  scoped to the GitHub **environment** claim rather than the branch claim, so
  environment protection rules sit between a merge and the ability to mint a
  production Azure token. Five purpose-scoped managed identities. The deploy
  identity holds **no Key Vault data-plane role**, because Container Apps
  resolves secret references with the container app's own identity — so the
  pipeline writes references and never sees values.
- **No database password exists either.** Microsoft Entra authentication for the
  API's managed identity, with a break-glass administrator credential retained
  in Key Vault solely to avoid a circular recovery dependency.
- **Egress enforcement for ADR-023 is a real network control**, not a code
  comment: NSG default-deny outbound plus a NAT gateway static egress IP, with
  the provider endpoint **absent by default** and added only on WP-11
  authorization as a named rule with an owner and an expiry.
- **Rollback is a traffic shift, not a rebuild** — multiple-revision mode with
  traffic splitting, and expand/contract migration discipline enforced by a CI
  check rather than by policy prose.
- **Backup custody is independent of the thing being backed up** — weekly
  logical long-term retention into a Backup vault plus an immutable audit
  archive, because Azure deletes a server's platform backups with the server.

### 2.3 Evidence classification, which is the point of the whole document

Every control is tagged `[P]` proposed, `[L]` locally verifiable later (provable
from repository artifacts with **no cloud resource, credential, or spend**), or
`[V]` provider-dependent (**only possible after G5**). Maximizing the `[L]` set
was a deliberate design goal: it lets `PH1-SEN-002` review real artifacts —
IaC, workflow YAML, migration-safety tests, seed-source tests, log-redaction
tests — while G5 is still closed, instead of reviewing prose. Stage 1 of the
validation plan (architecture §15) lists nine such pre-G5 activities.

---

## 3. Validation performed

| Check | Result |
|---|---|
| Four-file boundary | **Pass.** `git show --stat` reports exactly four added files, no modifications, no deletions. |
| `git diff --check` | **Pass.** No whitespace errors. |
| Clean status after commit | **Pass.** Working tree clean; no untracked files. |
| Branch and worktree isolation | **Pass.** Commit is on `phase1/ph1-shi-001` in the `PH1-SHI-001` worktree. No merge, no push, no other branch or worktree touched. |
| No cloud CLI, auth, resource, or deployment command | **Pass.** See §6 for the full attestation and the disclosed exception. |
| Source and link check | **Pass.** Every external URL cited was fetched successfully during the work, or is explicitly labelled as not independently retrieved (`U-02`, `U-08`, `U-11`, `U-12` in the cost proposal). Every Zaifu source citation was read from this worktree. |
| Arithmetic cross-check | **Pass, with one anomaly surfaced.** Two independent checks recorded in cost proposal §7.4: General Purpose per-vCore versus 2-vCore lines match exactly in East US 2 and Sweden Central; Burstable B2S = 4 × B1MS holds exactly in East US 2 and Mexico Central but **not** in Sweden Central, where B2S is exactly half the linear expectation. That anomaly is the reason Option B is cheapest, so it is flagged as `U-09` — the highest-leverage uncertainty — for confirmation on the vendor's own pricing page. |
| Self-review pass for deployment-implying language | **Two corrections applied.** A Sweden Central Profile M total (`$36.68`→`$37.27`) and the §7.1 share table, which mixed an Azure-only midpoint with an all-in Vercel line, were both corrected before commit. |
| Requirements traceability | **Pass.** Architecture §1.3 maps every design element to ADR-011/012/013/023/024/025, `SECURITY_ARCHITECTURE.md`, `THREAT_MODEL.md` TM-11/12/14/15, `DATA_CLASSIFICATION.md`, `OPEN_QUESTIONS.md`, WP-14's ten acceptance criteria, and `security-review.md` §§1/3/4/5/7/8. §12 gives the control-by-control matrix. |
| No claim of deployed controls | **Pass.** Every control carries `[P]`/`[L]`/`[V]`. Both documents open with an explicit "nothing is deployed" statement and close with a status section repeating it. `security-review.md` §5 is mapped to a non-Kubernetes analogue rather than silently claimed. |
| No security self-approval | **Pass.** Both documents state that the evidence is *submitted to* Sentinel and that Shinobi does not approve its own posture, per ADR-024 and `orchestration.md`. |
| Codex unused | **Pass.** Codex's Wave 1 review eligibility for `PH1-SEN-002` and `PH1-COD-001` is intact. |
| Interface reconciliation (follow-up commit) | **Pass.** `IC-01`–`IC-10` checked against `PH1-CLD-002` implementation commit `919b097`, read **read-only** from its worktree. Six resolved, four still pending and re-targeted, plus `IC-11` unchanged and `IC-13` added. Recorded in architecture §13 and cost proposal §9.5. |
| Read-only discipline on the `PH1-CLD-002` worktree | **Pass.** Only `git show`, `git ls-tree`, `git log`, `git remote -v`, and `cat` were used against that worktree. `git status --porcelain` there remains empty and its `HEAD` is unchanged at `b81bf56`. |

---

## 4. Interface assumptions and checkpoints — original position

At initial delivery, `shared/handoffs/PH1-CLD-002/` contained an assignment and
**no result**, so as the assignment requires, no application-interface assumption
was finalized. Twelve checkpoints were recorded in architecture §13, each with
its working assumption, why the platform needs it, and what changes if it is
wrong. Four were called out as consequential: `IC-08` (frontend rendering model,
a residency decision in disguise), `IC-03` (exact CI status-check names), `IC-07`
(migration invocation), and `IC-11` (audit-record ownership).

---

## 4A. Interface reconciliation against `PH1-CLD-002` — performed 2026-08-23

`PH1-CLD-002` has completed. Reconciliation was performed against its
implementation commit `919b0974d7f24749c017576a1faee39be4e3d9b4` and handoff
commit `b81bf56`, reading its worktree **read-only**. Nothing in that worktree
was modified, and no file outside this assignment's four owned paths was touched.

Full detail is in architecture **§13**, now titled "Interfaces to `PH1-WP-01` —
reconciled against `PH1-CLD-002`", and in cost proposal **§9.5**.

### 4A.1 Result

| ID | Status | Outcome |
|---|---|---|
| **IC-01** | **Resolved** | Assumption confirmed. `apps/api/` exists, no Dockerfile. Build context must be the repository root — forced by the pnpm catalog in `pnpm-workspace.yaml`, the root lockfile, `workspace:*` edges, and `apps/api/tsconfig.json` extending the root base config. No design change. |
| **IC-02** | **Resolved — changes the image design** | Package names exactly per DO-06. But consumption is **just-in-time TypeScript source**: `"exports": { ".": "./src/index.ts" }`, no build script, no `dist/`, **no emitted JavaScript anywhere**, zero production dependencies. See §4A.2. |
| **IC-03** | **Resolved — with a concrete hazard** | Job id `validate`, job `name: Validate workspace`. The required status check is the **display name**, `Validate workspace`. See §4A.3. |
| **IC-04** | **Resolved — exact versions known** | Node `24.18.0` via `.nvmrc`, pnpm `9.15.9` via `packageManager`, Corepack activation, single root lockfile at `lockfileVersion: '9.0'`, `engine-strict=true`, `strict-peer-dependencies=true`. The image builder now pins Node 24.18.0 by digest and takes the same Corepack path CI does. |
| **IC-05** | **Pending → re-targeted to WP-09** | No HTTP server, no route. Nothing to probe. Never WP-01's to answer. |
| **IC-06** | **Pending → re-targeted to WP-09** | No configuration module, no env reading. |
| **IC-07** | **Pending → re-targeted to WP-04** | No Prisma, no schema, no `packages/db`. The previous revision addressed the standalone-migration-command recommendation to WP-01; that was misdirected and is now routed to WP-04. |
| **IC-08** | **Pending → re-targeted to WP-13/WP-16, but nothing forecloses V1** | `apps/web` is a bare scaffold with **no framework dependency and no workspace dependency**, documented by WP-01 as "talks to the API over HTTP". The one edge that would have pushed toward pattern V2 was deliberately not created. Directional signal, not a decision. |
| **IC-09** | **Resolved — cleaner than assumed** | `.github/workflows/` contains exactly `ci.yml`; no `deploy-*.yml`. The workflow requests no `id-token`, no `secrets.*`, no environment, and no cloud provider. Architecture §5.3's "CI has no cloud access" is now a verifiable fact about a committed artifact, not a design intention. |
| **IC-10** | **Resolved** | `noEmit: true`, `declaration: false`, and decisively `moduleResolution: "bundler"`. Confirms IC-02 and settles §4A.2. |
| **IC-11** | **Pending — unchanged, WP-10** | Out of WP-01 scope. WP-10 owns the audit contract and wins any disagreement. |
| **IC-12** | Not applicable to WP-01 | Provider egress endpoint remains absent by default. |
| **IC-13** | **New** | Whether the API still bundles cleanly once Prisma is present. Owned jointly by WP-04 and WP-14. |

Six resolved, six pending (five re-targeted plus one new), one not applicable.

### 4A.2 The one real architecture consequence

WP-01 emits no JavaScript, so **the container build must introduce the
compilation step WP-01 deliberately omitted.** Two options existed: bundle inside
the image build, or switch the root `tsconfig.base.json` to composite project
references and emit `dist/`.

**Resolved in favour of bundling inside the image build**, and the reason is
stronger than preference: WP-01's `tsconfig.base.json` already sets
**`moduleResolution: "bundler"`**, so the composite route would require changing
that setting too — it is a change to WP-01's deliberate toolchain choice, while
bundling is the path that configuration already points at. It also keeps the
runtime-artifact decision inside the package that owns the image.

A dividend worth naming: with zero production dependencies, a bundled single-file
artifact means the runtime image carries **no package manager and no
`node_modules`**, which turns the "non-root, read-only root filesystem, no shell
in the final layer" posture from aspiration into the easy default.

The honest caveat is recorded as `IC-13`: Prisma's client ships platform-native
query-engine binaries that do not bundle cleanly, so when WP-04 introduces
Prisma this must be re-tested and may need a hybrid image.

### 4A.3 The status-check hazard, now concrete

The previous revision flagged `IC-03` as the highest-consequence, lowest-effort
item on the checkpoint list. It was right, and now it is specific.

For a GitHub Actions job the check name surfaced to branch protection is the
job's **display name**, not its id. WP-01 declares job id `validate` with
`name: Validate workspace`. WP-01's own handoff §6.1 recommends requiring "the
`validate` check", which is the id. Configuring a ruleset with `validate` when
GitHub reports `Validate workspace` yields a required check that is never
satisfied — the branch blocks forever, or the rule gets relaxed and the gate is
silently open.

**And nobody has observed the real string yet**, because CI has never executed —
WP-01 §8.2 records that there is no remote, so there has been no workflow run.
The required order is therefore: host the repository → let `Validate workspace`
run once → **read the check name off the real run** → only then configure the
ruleset. This is `[V]`, not `[L]`; it cannot be proven from the repository.

### 4A.4 A new prerequisite nobody owns — `DP-09`

`PH1-CLD-002` §6.1 confirms `git remote -v` returns nothing: **the repository has
no Git remote and no host.** This blocks more of the architecture than it first
appears. A federated identity credential's subject names an organization and a
repository, so the entire identity design in architecture §5.2 is
*unimplementable*, not merely unapproved, until the repository is hosted. So are
GitHub Environments with required reviewers — the control that makes production
approval load-bearing — branch protection, the required status check above, and
secret scanning.

**Repository creation is therefore a gate, and it is the moment `DP-03` must be
answered**, because public-versus-private decides whether secret scanning is free
or a `$19`-per-committer product, and it cannot be undone for anything already
pushed. It costs nothing and needs **no G5 approval**, but it sits on the critical
path for every workflow-bearing pre-G5 artifact in architecture §15 Stage 1 —
and no work package currently owns it. Recorded as `DP-09`.

### 4A.5 Two smaller findings folded into the design

- **Install lifecycle scripts execute during the image build.** WP-01's `.npmrc`
  does not set `ignore-scripts` (its §8.7 records this as deliberate and
  reversible). That is a supply-chain execution surface the previous revision did
  not account for. Added as a control row in architecture §10.4: run the image
  build's install with `--ignore-scripts` where the dependency set permits, and
  otherwise record the specific dependency, justification, and owner.
- **Five supply-chain properties are already satisfied in `ci.yml`** — SHA-pinned
  first-party actions, `permissions: contents: read` at both workflow and job
  level with no `id-token`, no `secrets.*` reference, `persist-credentials: false`,
  and `--frozen-lockfile` install. Architecture §13.4 records them as satisfied
  **for CI** and still `[P]` for the `deploy-*.yml` workflows WP-14 owns.

### 4A.6 What did not change

**No cost figure moved, and cost proposal §9.5 records why:** WP-01's committed
tree contains no Dockerfile, no IaC, no `deploy-*.yml`, and zero production
dependencies — verified by `git ls-tree -r` over the implementation commit
returning no match for `docker`, `infra`, `bicep`, `terraform`, `deploy`, or
`prisma`. The topology, identity model, encryption design, network design, and
backup and rollback designs are all unaffected. Assumption `A-11` (container
images under 10 GiB) is confirmed and currently very conservative.

## 5. Findings the orchestrator should act on

| ID | Finding | Why it is time-sensitive |
|---|---|---|
| **F-01** | **Three production-critical choices are creation-time-only and irreversible:** geo-redundant backup, customer-managed key encryption, and the primary region itself. Azure documents that CMK "can be configured only during creation of a new server", cannot be reverted, and that geo-redundant backup "can be configured only when you create the server". | **This changes the shape of D-04.** Region, residency, redundancy, and key-management posture must be answered *together*, before the first production server exists. Getting any one wrong is a migration, not a configuration change. `PH1-CLD-001` framed D-04 as "spend, region, and residency"; it needs two more elements. |
| **F-02** | **WP-14 acceptance criterion 2 — "secret scanning is enabled and clean" — is not satisfiable on GitHub Free with no spend.** Secret scanning and push protection for private repositories require GitHub Secret Protection at a published `$19` per active committer per month. Three options are laid out in architecture §10.5 with a recommendation. | Discovering this at G6 would be worse than deciding it now. Recorded as `DP-03`. |
| **F-03** | **A Container Apps *consumption-only* environment structurally cannot enforce the ADR-023 network-layer egress allowlist** — it "doesn't support UDRs, egress through Azure NAT Gateway… or other custom egress". A workload-profiles environment with a custom VNet is therefore not an optimization; it is a requirement flowing from ADR-023. | Constrains the environment type before any IaC is written. |
| **F-04** | **Deleting a PostgreSQL Flexible Server deletes all its backups, unrecoverably.** This makes platform PITR alone a circular recovery dependency under TM-12 and TM-15, and it is exactly what `security-review.md` §8 forbids. | Three controls are proposed (resource lock, long-term retention under separate custody, immutable audit archive). Sentinel should confirm the set is sufficient. |
| **F-05** | **Brazil South is paired with South Central US, outside the Brazil geography.** Enabling geo-redundant backup there replicates Restricted financial data to the United States. **Mexico Central is non-paired** and has no in-country DR target at all. | Recorded so that neither is proposed later as a Latin-American residency answer. Both are trap-shaped. |
| **F-06** | **Sweden Central is the cheapest hardened option**, roughly `$15`/month below East US 2, driven by a B2S rate that is exactly half the linear expectation from B1MS. | Genuine finding if the rate is real (`U-09`); it means an EU-residency requirement carries no cost penalty. Confirm before a decision rests on it. |
| **F-07** | `PH1-CLD-001` finding **C-17** — `.gitignore` ignores `*.pdf` globally — will silently block any PDF platform evidence artifact. | Platform evidence must be text, JSON, CSV, or PNG until WP-02 narrows the rule. `.gitignore` is outside this assignment's four owned files, so it was **not** changed. |
| **F-08** | **Container Apps private endpoints incur a `$0.10`/hour Dedicated Plan Management charge (≈ `$73`/month) regardless of plan type.** | Neither costed profile incurs it, because pattern V1 needs external ingress. But if inbound private link is later required — an Azure Front Door origin, for instance — it is a step change, not a tweak. |
| **F-09** *(reconciliation)* | **The repository has no Git remote and no host.** That makes the entire OIDC identity design *unimplementable*, not merely unapproved, because a federated credential's subject names an organization and repository. Branch protection, GitHub Environments with required reviewers, and secret scanning are all repository-host features. | Recorded as **`DP-09`**. It costs nothing and needs no G5 approval, but it is on the critical path for every workflow-bearing pre-G5 artifact and **no work package currently owns it**. Repository creation is also the moment `DP-03` (public versus private, and therefore whether Secret Protection is needed) must be answered, and that choice cannot be undone for anything already pushed. |
| **F-10** *(reconciliation)* | **The required status check is `Validate workspace`, the job's display name — not `validate`, the job id that WP-01's own handoff §6.1 recommends.** A mismatch yields a check that is never satisfied: the branch blocks forever, or the rule is relaxed and the gate is silently open. | And **nobody has observed the real string**, because CI has never executed (no remote). Required order: host the repository → let it run once → read the check name off the real run → then configure the ruleset. |
| **F-11** *(reconciliation)* | **WP-01 emits no JavaScript** — `noEmit: true`, no `dist/`, packages export `./src/index.ts`. The container build must introduce the compilation step WP-01 deliberately omitted. | Resolved in favour of bundling inside the image build, because `tsconfig.base.json` already sets `moduleResolution: "bundler"`, so the composite-project-references alternative would require changing WP-01's toolchain choice. Re-test when WP-04 adds Prisma (`IC-13`) — its native query-engine binaries do not bundle cleanly. |

---

## 6. Prohibited-action attestation

For the entire execution of `PH1-SHI-001`:

- **No** Azure, Vercel, GitHub, or DNS resource was created, modified, or deleted.
- **No** IaC was authored or executed. No Terraform, Bicep, ARM, `az`, `azd`,
  `vercel`, `gh` write operation, `kubectl`, `helm`, or Docker build was
  installed or invoked. No `plan`, `apply`, `deploy`, `push`, or `login` of any
  kind was run.
- **No** credential, secret, token, certificate, service principal, managed
  identity, or key was created, read, requested, stored, or used.
- **No** authenticated provider console, portal, or management API was accessed.
- **No** deployment, DNS change, domain purchase, plan selection, tier selection,
  reservation, purchase, commitment, or spend of any kind occurred.
- **No** production action and **no** destructive action of any kind occurred.
- **No** security self-approval was given. Both documents state explicitly that
  their evidence is submitted to Sentinel and approves nothing.
- **No** file outside the four owned paths was created, modified, or deleted, in
  this repository or in Ninjatronics. `shared/handoffs/PH1-SHI-001/` was read
  only.
- Work was confined to the `PH1-SHI-001` worktree and the `phase1/ph1-shi-001`
  branch. No merge, no push, no rebase; no other branch was modified.
- **The interface reconciliation (§4A) read the `PH1-CLD-002` worktree
  read-only.** Only `git show`, `git ls-tree`, `git log`, `git remote -v`, and
  `cat` were used against it. Nothing there was created, modified, staged,
  committed, or deleted; its `HEAD` is unchanged at `b81bf56` and its
  `git status --porcelain` is empty. No other agent's worktree was touched.
- **Codex was not used**, in either the initial delivery or the reconciliation
  follow-up. No subagent, agent tool, or workflow was dispatched at any point.
- The reconciliation performed **no** cloud, resource, deployment, credential,
  DNS, or spend action of any kind, and required no network access beyond what
  was already used for the initial delivery.

**One disclosed exception, so that it is classified by a reviewer rather than
inferred.** Pricing research used the **Azure Retail Prices** endpoint,
`https://prices.azure.com/api/retail/prices`. It is public, anonymous, and
read-only; it requires no account, credential, or subscription; it returns
published list prices; and it cannot create, change, read, or bill any resource.
It is documentation in machine-readable form, not a management-plane call, and it
falls outside every prohibition above. It is disclosed in the attestation
sections of both deliverables as well as here. If the orchestrator or Sentinel
judges that any provider-hosted endpoint is out of bounds regardless of these
properties, the unit-price table in the cost proposal can be re-sourced from the
equivalent published pricing pages; the figures and the analysis would not
change, only the citation form.

All other research used ordinary public documentation pages and web search. No
authentication was performed against any provider.

---

## 7. Deliverable status and residual gates

| Gate / decision | Status after this handoff |
|---|---|
| **G5** — cloud spend, region, residency, resource creation | **Closed. Untouched.** |
| **D-04** — spend, region, residency | **Open**, and per F-01 it now needs to also settle geo-redundancy and key management |
| `DP-01` geo-redundant backup | Open — creation-time only |
| `DP-02` service-managed versus customer-managed keys | Open — creation-time only; recommendation is service-managed for Phase 1, for Sentinel to confirm |
| `DP-03` secret-scanning approach | Open — see F-02. **Must be answered at repository-creation time** (F-09) |
| `DP-04` frontend data path V1/V2/V3 | Open — `IC-08` is still pending, re-targeted to WP-13/WP-16. Reconciliation found nothing in WP-01 forecloses V1 |
| `DP-05` acceptance of the proposed RPO/RTO | Open — and the values are estimates that a timed rehearsal must replace |
| `DP-06` acceptance of residual risks R-01…R-10 | Open |
| `DP-07` whether WAF and Azure Firewall are required rather than deferred | Open — Sentinel judgement |
| `DP-08` whether ACR Premium with private link is required rather than recommended | Open — worth `$45.62`/month |
| `DP-09` **create and host the Git repository**, deciding public versus private at that moment | **Open and unowned** — see F-09. Costs nothing, needs no G5 approval, blocks every workflow-bearing pre-G5 artifact |
| `IC-05`, `IC-06` | Open — re-targeted to **WP-09** |
| `IC-07` | Open — re-targeted to **WP-04** |
| `IC-08` | Open — re-targeted to **WP-13 / WP-16** |
| `IC-11` | Open — **WP-10** owns the audit contract |
| `IC-13` | **New.** Whether the API bundles cleanly once Prisma is present — **WP-04 + WP-14** |
| **G6** | Not addressed. Out of scope. |

**Nothing in WP-14 is complete.** This assignment delivers the design and the
decision-ready options. The ten WP-14 acceptance criteria remain unmet, and
criteria 5 and 10 — a restore actually performed, and a rollback actually
exercised — **cannot** be met before G5 by any amount of design work. That is
stated plainly rather than papered over.

---

## 8. Recommended next steps

1. **Orchestrator** — validate both commits independently; confirm the four-file
   boundary and the attestation; decide whether the disclosed retail-price
   endpoint is acceptable as a source (§6).
2. **Orchestrator** — carry F-01 into the D-04 framing so Gerso is asked one
   composite question (spend, region, residency, geo-redundancy, key management)
   rather than three sequential ones, two of which would arrive too late.
3. **Orchestrator — assign an owner to `DP-09`.** This is the new ask from
   reconciliation. Creating and hosting the repository costs nothing, needs no
   G5 approval, and unblocks the entire GitHub half of the architecture — but no
   work package owns it today, and `DP-03` must be answered at the same moment.
4. **Orchestrator** — route `IC-05` and `IC-06` to WP-09, `IC-07` to WP-04,
   `IC-08`/`DP-04` to WP-13/WP-16, `IC-11` to WP-10, and `IC-13` jointly to
   WP-04 and WP-14. The previous revision addressed `IC-07` to WP-01; that was
   misdirected and is corrected in §4A.1.
5. **Orchestrator** — pass F-10 to whoever configures branch protection. The
   check name is `Validate workspace`, it has never been observed on a real run,
   and it must be read off the first run before any ruleset is written.
6. **`PH1-SEN-002`** (Codex carrying Sentinel rules; eligibility intact) —
   independent security review, with specific verdicts requested on `DP-02`
   (CMK availability trade), `DP-03` (secret scanning), `DP-07` (WAF and
   firewall), `DP-08` (registry tier), the sufficiency of the F-04
   backup-custody control set, and — added by reconciliation — the
   `--ignore-scripts` position in architecture §13.4 alongside WP-01's own
   §8.7 flag on the same setting.
7. **Gerso** — G5 / D-04 when ready, informed by the cost proposal §10
   recommendation and its §11 uncertainties, with `U-09` confirmed first.
8. **Only after G5** — WP-14 implementation. Note that architecture §15 Stage 1
   now lists the repository-hosting step as its first item, and that the nine
   `[L]` artifacts behind it can begin as soon as design approval, `DP-09`, and
   WP-01 integration land — with no spend.

---

## 9. Reviewer notes

**Reviewer:** Nova for validation; `PH1-SEN-002` for architecture security
controls.
**This handoff and both deliverables constitute submitted evidence, not
approval.** Per ADR-024 and `orchestration.md`, Shinobi does not approve its own
security posture, and no control described in these documents is verified,
deployed, or operating.
