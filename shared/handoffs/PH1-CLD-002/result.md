# Handoff: PH1-CLD-002 — WP-01 monorepo foundation and toolchain

**Specialist role:** Forge, executed by Claude Code as approved.
**Assignment:** `docs/orchestration/assignments/PH1-CLD-002.md`
**Completed:** 2026-08-23
**Branch / worktree:** `phase1/ph1-cld-002` in an isolated assignment worktree.
**Implementation commit:** `919b0974d7f24749c017576a1faee39be4e3d9b4`
**Recommended next owner:** Active orchestrator for independent validation and
integration, then PH1-SEN-002 for repository/CI security review when authorized.

---

## 1. Summary

Zaifu now has a pnpm/TypeScript workspace, a strict type/lint/format/test
validation baseline, minimal scaffolding for two applications and the three
approved engine packages, and a least-privilege CI workflow that installs from
the lockfile and runs the same validation commands used locally.

The change contains **no product behavior**. There is no financial, forecast,
decision, Koban, authentication, API, UI, persistence, schema, infrastructure,
deployment, or cloud logic. The only code in the repository is a package-name
constant per workspace package plus the workspace-edge imports needed to prove
that cross-package resolution, type checking, and testing actually work.

---

## 2. Inspected tool versions

Versions were read from the local environment, not assumed.

| Tool | Version | How inspected |
|---|---|---|
| Node.js | `v24.18.0` | `node --version` |
| pnpm | `9.15.9` | `pnpm --version` |
| npm | `11.16.0` | `npm --version` |
| Corepack | `0.35.0` | `corepack --version` |
| Git | `2.43.0` | `git --version` |

`packageManager` is pinned to `pnpm@9.15.9` — the installed version — and
`engines` declares `node >=24.18.0` and `pnpm >=9.15.9 <10`. `.nvmrc` records
`24.18.0` and is the single source CI reads. pnpm reported that `11.23.0` is
available; the pin deliberately matches the inspected local version rather than
introducing an untested upgrade inside this assignment.

### 2.1 Dependency versions and why

All development dependencies are resolved through a pnpm **catalog** in
`pnpm-workspace.yaml`, so every package references one version.

| Dependency | Version | Notes |
|---|---|---|
| `typescript` | `6.0.3` | See the constraint below. |
| `typescript-eslint` | `8.67.0` | Latest published. |
| `eslint` | `10.9.0` | Latest published. |
| `@eslint/js` | `10.0.1` | Latest published. |
| `prettier` | `3.9.6` | Latest published. |
| `vitest` | `4.1.11` | Latest published. |

**Material constraint found by inspection, not guessed.** `typescript@7.0.2` is
the latest published stable TypeScript, but
`npm view typescript-eslint@8.67.0 peerDependencies` declares
`typescript: >=4.8.4 <6.1.0`. Type-aware linting is a WP-01 acceptance
requirement, so TypeScript is pinned to `6.0.3` — the newest stable release that
the lint toolchain supports. This is a reversible pin, not an architecture
decision: when `typescript-eslint` widens its peer range, bump the single
catalog entry. Recorded here so no later package re-litigates it.

Total installed dependency graph: **131 packages**, lockfile
`lockfileVersion: '9.0'`.

---

## 3. What was created

### 3.1 Changed files (32 files, all newly added; no existing file modified)

Root toolchain and configuration:

```
.npmrc
.nvmrc
.prettierignore
.prettierrc.json
eslint.config.mjs
package.json
pnpm-lock.yaml
pnpm-workspace.yaml
tsconfig.base.json
```

CI:

```
.github/workflows/ci.yml
```

Application and package scaffolding:

```
apps/api/package.json
apps/api/tsconfig.json
apps/api/src/index.ts
apps/api/src/index.test.ts
apps/web/package.json
apps/web/tsconfig.json
apps/web/src/index.ts
apps/web/src/index.test.ts
packages/decision-engine/package.json
packages/decision-engine/tsconfig.json
packages/decision-engine/src/index.ts
packages/decision-engine/src/index.test.ts
packages/financial-engine/package.json
packages/financial-engine/tsconfig.json
packages/financial-engine/src/index.ts
packages/financial-engine/src/index.test.ts
packages/forecast-engine/package.json
packages/forecast-engine/tsconfig.json
packages/forecast-engine/src/index.ts
packages/forecast-engine/src/index.test.ts
```

Project-local orchestration records:

```
docs/orchestration/assignments/PH1-CLD-002.md
docs/orchestration/handoffs/PH1-CLD-002.md
```

Nothing outside this list was created, modified, or deleted. In particular
`.gitignore`, `README.md`, and every existing document under `docs/` and
`shared/` are untouched.

### 3.2 Package names (exact, per ADR-019 / DO-06)

| Directory | `name` field | Product/domain name |
|---|---|---|
| `packages/financial-engine` | `financial-engine` | Ledger |
| `packages/forecast-engine` | `forecast-engine` | Oracle |
| `packages/decision-engine` | `decision-engine` | Strategist |
| `apps/api` | `api` | — |
| `apps/web` | `web` | — |

Names are unscoped and exactly as DO-06 fixes them. No npm scope was invented,
because DO-06 did not authorize one and "package names are exact" is a
validation requirement. Every package is `"private": true` and is never
published. `packages/automation-engine` (Steward) was **not** created, per
planning assumption A-05.

### 3.3 Workspace dependency graph

Edges follow ADR-002's one-directional engine architecture. They exist to prove
resolution works, not to expose behavior.

```
financial-engine  ──────────────► forecast-engine ──┐
        │                                            ├──► decision-engine
        └────────────────────────────────────────────┘
                                                        │
financial-engine, forecast-engine, decision-engine  ────┴──► apps/api

apps/web  (no workspace dependency; talks to the API over HTTP)
```

Verified acyclic by topological sort over the five manifests:

```
financial-engine -> web -> forecast-engine -> decision-engine -> api
```

`pnpm -r list --depth 0` confirms every internal edge resolves as a
`workspace:*` link, and that the only third-party dependencies present anywhere
are the six development tools listed in §2.1. There are **zero production
dependencies** in the repository.

---

## 4. Design decisions and tradeoffs

1. **Just-in-time internal packages instead of composite builds.** Each package
   exposes `"exports": { ".": "./src/index.ts" }`, and typechecking is
   `tsc --noEmit`. Nothing is emitted, so there is no build step, no `dist/`,
   and no build-order coupling in CI. *Tradeoff:* a Node runtime that needs
   emitted JavaScript (the eventual API server, WP-09) will require either a
   bundler or a switch to composite project references. That is a one-file
   change to `tsconfig.base.json` plus per-package `exports`, and it is called
   out here so WP-04/WP-09 can decide deliberately.
2. **Version catalog rather than repeated version strings.** Sub-packages
   declare the tools they actually execute (`eslint`, `typescript`, `vitest`)
   so `pnpm -r lint|typecheck|test` works per package with no phantom
   dependencies, while `catalog:` keeps a single authoritative version.
3. **Two lint entry points.** `pnpm run lint` is one type-aware ESLint pass over
   the whole tree, including `eslint.config.mjs` itself (11 files).
   `pnpm run lint:packages` runs `pnpm -r lint` so each package is
   independently lintable, which is WP-01 acceptance criterion 2. CI runs both.
4. **Prettier does not format documentation.** `.prettierignore` excludes
   `docs/`, `shared/`, and `README.md`. Reflowing that prose would edit files
   this assignment does not own and would collide with PH1-ARC-001 (WP-02).
   Markdown formatting policy is therefore an open item for the documentation
   owner, recorded in §8.
5. **No dependency cache in CI.** Only SHA-pinned first-party `actions/*` are
   used; pnpm is activated through Corepack from the `packageManager` field.
   Adding a cache would require a third-party or additional action for a
   scaffold whose install takes well under a second from a warm store.
   *Tradeoff:* slightly slower cold CI runs, in exchange for a smaller
   supply-chain surface for PH1-SEN-002 to review.
6. **`skipLibCheck: true`.** Standard practice; it limits strictness to
   first-party code rather than to third-party declaration files. Flagged
   explicitly because the assignment requires strict settings.

---

## 5. Validation performed

All commands were run from the worktree root unless noted. Every command exited
`0`.

| # | Command | Result |
|---|---|---|
| V1 | `pnpm install` | 131 packages added; lockfile written at `lockfileVersion: '9.0'`. |
| V2 | `pnpm install --frozen-lockfile` | "Lockfile is up to date, resolution step is skipped. Already up to date." |
| V3 | `pnpm run format` (`prettier --check .`) | "All matched files use Prettier code style!" — 26 owned files matched. |
| V4 | `pnpm run lint` (`eslint . --max-warnings=0`) | 11 files linted, 0 errors, 0 warnings. |
| V5 | `pnpm run lint:packages` (`pnpm -r lint`) | 5 of 5 packages pass. |
| V6 | `pnpm run typecheck` (`pnpm -r tsc --noEmit`) | 5 of 5 packages pass. |
| V7 | `pnpm run test` (`pnpm -r vitest run`) | 5 test files, **9 tests, 9 passed, 0 failed, 0 skipped**. |
| V8 | `pnpm run validate` | Full chain V3→V7 in one run; exit `0`. |
| V9 | `pnpm -r list --depth 0` | Workspace graph as documented in §3.3. |
| V10 | Topological sort of all five manifests | Acyclic; order in §3.3. |
| V11 | `git diff --check` and `git diff --cached --check` | Clean; no whitespace errors. |
| V12 | `git status --porcelain` after commit | Empty. |

### 5.1 Clean-checkout reproduction

The committed tree was extracted with
`git archive 919b097 | tar -x` into a directory with no `node_modules`, then:

- `pnpm install --frozen-lockfile` → 131 packages, exit `0`.
- `pnpm run validate` → format, lint, lint:packages, typecheck, and all 9 tests
  pass, exit `0`.

Package resolution came from the local pnpm store on this run
(`reused 131, downloaded 0`); resolution itself is fully pinned by the lockfile,
so a cold store fetches the same versions.

### 5.2 Negative tests — the gates actually fail when they should

A passing pipeline over trivial code proves little, so each gate was
deliberately broken and then reverted:

| Gate | Injected defect | Observed |
|---|---|---|
| Lint | `export const NEGATIVE_TEST: any = 1;` in `packages/financial-engine` | `error @typescript-eslint/no-explicit-any` — "Unexpected any. Specify a different type"; exit `1`. |
| Typecheck | `const NEGATIVE_TEST: string = UPSTREAM_PACKAGES[0];` | `error TS2322: Type 'string \| undefined' is not assignable to type 'string'` (from `noUncheckedIndexedAccess`); exit `2`. |
| Format | `export const   NEGATIVE_TEST="unformatted"` | Prettier reported a style issue; exit `1`. |

The working tree was restored after each test; the committed tree contains none
of these lines.

### 5.3 Strict TypeScript settings in force

`tsconfig.base.json` sets `strict: true` plus `noUncheckedIndexedAccess`,
`exactOptionalPropertyTypes`, `noImplicitOverride`, `noImplicitReturns`,
`noFallthroughCasesInSwitch`, `noUnusedLocals`, `noUnusedParameters`,
`noPropertyAccessFromIndexSignature`, `useUnknownInCatchVariables`,
`allowUnreachableCode: false`, `allowUnusedLabels: false`, `isolatedModules`,
`verbatimModuleSyntax`, `erasableSyntaxOnly`,
`forceConsistentCasingInFileNames`, and `types: []`.

ESLint applies `strictTypeChecked` + `stylisticTypeChecked` from
`typescript-eslint` with `projectService: true` to every TypeScript file, and a
dedicated `packages/*-engine/**` block re-asserts `no-explicit-any` plus the
five `no-unsafe-*` rules as errors — WP-01 acceptance criterion 4.

---

## 6. CI configuration evidence

`.github/workflows/ci.yml`, reviewed locally by parsing the YAML and by reading
it line by line. `actionlint` is not installed on this machine and no global
install was performed, so the review is a parse plus manual inspection, not an
`actionlint` clean run.

- **Triggers:** `pull_request` → `main`, `push` → `main`.
- **Permissions:** `contents: read` at the workflow level and re-declared
  `contents: read` on the single job. No `id-token`, no `packages`, no
  `pull-requests`, no write scope anywhere.
- **Secrets:** the workflow references **no** `secrets.*` value, no environment,
  no OIDC token, no registry credential, and no cloud provider. Grep for
  `secrets.` returns nothing.
- **Actions:** only first-party actions, pinned to full commit SHAs —
  `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1) and
  `actions/setup-node@820762786026740c76f36085b0efc47a31fe5020` (v7.0.0). Both
  SHAs were resolved from the GitHub tag refs API at authoring time.
- **Token hygiene:** `persist-credentials: false` on checkout, since no step
  pushes.
- **Hardening:** `timeout-minutes: 15`, `concurrency` with
  `cancel-in-progress`, `COREPACK_ENABLE_DOWNLOAD_PROMPT: '0'`.
- **Steps:** checkout → set up Node from `.nvmrc` → Corepack activate pnpm from
  the `packageManager` field → `pnpm install --frozen-lockfile` →
  `pnpm -r list --depth 0` → format → lint (both entry points) → typecheck →
  test. No build, publish, deploy, IaC, or cloud step exists.

### 6.1 Repository-host controls — not configured, not claimed

**Secret scanning, push protection, and branch protection are NOT enabled, and
this assignment did not enable them.**

This repository has **no Git remote** (`git remote -v` returns nothing) and no
repository host, so there is nothing to configure and nothing to screenshot.
Repository-host settings are also explicitly out of scope for this assignment.
WP-01 acceptance criterion 5 ("secret scanning is enabled") is therefore
**not met and cannot be met locally**. It is reported as outstanding rather
than fabricated.

Required follow-up, for whoever creates the hosted repository (PH1-SEN-002 scope
when authorized):

1. Enable secret scanning and push protection.
2. Require the `validate` check on `main` via branch protection, with linear
   history and no force-push.
3. Restrict who may change `.github/workflows/**`.
4. Capture the settings evidence WP-01 asks for at that point.

---

## 7. Acceptance criteria status (PH1-WP-01)

| # | Criterion | Status |
|---|---|---|
| 1 | `pnpm install` succeeds from a clean checkout | **Met** — §5.1 |
| 2 | `pnpm -r lint`, `pnpm -r typecheck`, `pnpm -r test` all succeed and are wired into CI on pull request | **Met** — V5–V7, §6 |
| 3 | Workspace directory names match the ADR-019 code names | **Met** — §3.2, per DO-06 |
| 4 | TypeScript strict mode on; `any` lint-blocked in engine packages | **Met** — §5.3, negative test in §5.2 |
| 5 | Secret scanning enabled on the repository | **Not met** — no remote/host exists; see §6.1. Reported, not fabricated. |
| 6 | No workspace dependency cycle; `pnpm -r list` acyclic | **Met** — §3.3, V9, V10 |

**Overall: met except criterion 5, which is not achievable locally and is out of
this assignment's scope.**

---

## 8. Risks, limitations, and open items

1. **Criterion 5 is open.** Repository security controls remain unconfigured
   because no host exists. Tracked in §6.1.
2. **CI has never executed.** There is no remote, so no workflow run and no run
   URL exists. The workflow was validated by local parse and by running every
   command it runs. First execution will occur when the repository gains a host.
3. **TypeScript is one major version behind the latest.** Pinned at `6.0.3` by
   the `typescript-eslint` peer range (§2.1). Revisit when that range widens.
4. **No emitted JavaScript.** Packages resolve through TypeScript source. The
   API application will need a bundler or composite builds before it can run
   under Node (§4.1).
5. **`skipLibCheck` is on** (§4.6).
6. **Markdown formatting policy is undecided.** Prettier ignores `docs/`,
   `shared/`, and `README.md` (§4.4). The documentation owner (PH1-ARC-001 /
   WP-02) should decide whether prose is formatted, and this exclusion should be
   revisited then.
7. **`ignore-scripts` is not set** in `.npmrc`. Blocking install scripts would
   harden supply-chain posture, but the current toolchain relies on platform
   binary resolution, so it was left enabled rather than risking a broken
   install. Flagged for PH1-SEN-002 as a deliberate, reversible choice.
8. **pnpm 9.15.9 emits a Node 24 deprecation warning** (`DEP0169`,
   `url.parse()`) on every invocation. It originates inside pnpm itself, not in
   this repository, and does not affect any exit code. It disappears on a pnpm
   upgrade, which is deliberately not part of this assignment (§2).
9. **Two apps and three engines only.** `packages/automation-engine` (Steward)
   was not created (A-05), and no shared domain-types package was created
   because this assignment's ownership does not include such a path. If WP-04
   needs one, that is a new owned path and should be granted explicitly.

No escalation condition was triggered: no package-name or layout change was
needed, no product behavior was required, and the one tool incompatibility found
(§2.1) was resolved by version selection rather than by an architecture choice.

---

## 9. Prohibited-action attestation

- No product behavior of any kind was implemented: no financial, forecast,
  decision, Koban, authentication, API, UI, persistence, schema, or business
  logic exists in this change.
- **No cloud resource was created**, no infrastructure was provisioned, no
  deployment occurred, no IaC was written or applied, and **no spend was
  incurred**.
- No credential, secret, token, or key was created, read, used, or committed.
  No DNS, no production system, and no repository-host setting was touched.
- No file outside this assignment's exclusive ownership was created, modified,
  or deleted. No existing document was edited.
- No system or global package was installed. All installation was
  project-local through pnpm and is fully represented in `pnpm-lock.yaml`.
- Work stayed in the `phase1/ph1-cld-002` worktree and branch. Nothing was
  merged, pushed, rebased, or altered in another branch or worktree, and no
  remote exists.
- **Codex was not used** for any part of this work, so it remains eligible to
  review this artifact.
- No follow-up agent, subagent, or workflow was dispatched.

---

## 10. Recommendations for the next owner

1. Validate independently: clean checkout, `pnpm install --frozen-lockfile`,
   `pnpm run validate`.
2. Confirm the DO-06 names and the ADR-002 edge direction in §3.2 and §3.3 match
   the intended architecture before WP-04 lands anything on top of them.
3. Route §6.1 and §8.7 to PH1-SEN-002 when repository security review is
   authorized.
4. Decide the Markdown formatting policy (§8.6) alongside PH1-ARC-001's WP-02
   documentation reconciliation.
5. Decide before WP-09 whether the API is bundled or built with composite
   project references (§8.4).

---

*Handoff completed 2026-08-23. Implementation commit
`919b0974d7f24749c017576a1faee39be4e3d9b4`; this handoff and the project-local
assignment are committed separately so the handoff can cite that SHA.*
