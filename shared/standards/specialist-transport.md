# Retired Specialist Transport Standard (historical evidence only)

> **Non-operative as of 2026-08-23.** Hermes is prohibited as an execution
> runtime. Do not probe, test, dispatch, retry, or fall back to Hermes. Only
> Claude Code and Codex may execute specialist roles. Every command and
> imperative below documents the retired transport and must not be used for new
> work.

## Historical purpose

This standard defines how Nova dispatches an assignment to a real named Hermes
specialist profile (initially `sentinel` and `archivist`) through Herdr, waits
for completion, captures the specialist's response, verifies profile identity,
persists evidence, and cleans up.

The transport is implemented by `scripts/dispatch-specialist.sh` (with helper
libraries `scripts/lib/herdr.sh` and `scripts/lib/markers.sh`). Nova invokes the
dispatcher; Nova does not need to know which internal transport method is used.

The command contract below was discovered empirically against Herdr v0.7.5
(assignment PH6-CLD-001) and validated end-to-end against the real `sentinel`
and `archivist` profiles (assignment PH6-COD-002).

## Scope

- Applies to routing security/compliance review to Sentinel and
  documentation/evidence work to Archivist as real independent Hermes profiles.
- The allow-list is intentionally small (`sentinel`, `archivist`) and lives in a
  single array in `dispatch-specialist.sh` (`ALLOWED_PROFILES`). Extend it there.

## Transport methods

Both methods sit behind the same dispatcher interface. `--transport auto`
(default) uses the marker method.

### 1. Marker-based interactive Herdr transport (PRIMARY)

This is the required primary transport. It launches an interactive `hermes`
agent inside a Herdr pane, so the specialist execution is visible and
manageable through Herdr (workspace/pane/tab/terminal identifiers, live
transcript, `herdr agent list`).

Command sequence (all `herdr agent`/`pane`/`workspace` commands emit
single-line JSON on stdout; **error JSON is emitted on STDERR** with exit 1):

1. Precheck: `herdr status` → `server: status: running`.
2. `herdr workspace create --label <label> --cwd <workdir> --no-focus`
   → parse `result.root_pane.pane_id`.
3. `herdr agent start <name> --kind hermes --pane <pane_id> -- -p <profile>`
   → assert `result.argv == ["hermes","-p","<profile>"]` and
   `result.agent.interactive_ready == true`. A freshly-created pane may report
   `agent_pane_busy` for a moment; the dispatcher retries with backoff.
4. `herdr agent prompt <pane_id> "<marker-wrapped prompt>" --wait --until done
   --until idle --until blocked --timeout <ms>` → blocks; returns
   `agent_status`.
5. `herdr pane process-info --pane <pane_id>` → foreground process name
   `hermes` (alive) or `bash` (crashed/exited). Also used to corroborate
   identity via the `hermes -p <profile>` cmdline.
6. `herdr pane wait-output <pane_id> --regex <end-marker> --timeout <ms>` then
   `herdr agent read <pane_id> --source recent-unwrapped --lines <N>` → rendered
   scrollback; the answer is extracted strictly between the assignment markers.
7. Teardown (per-agent only): `herdr pane send-text <pane_id> "/quit"` →
   `herdr agent send-keys <pane_id> enter` → `herdr pane close <pane_id>`;
   verify gone via `herdr agent get <pane_id>` → `agent_not_found`.

### 2. `hermes -z` one-shot (SECONDARY, `--transport zexec`)

`hermes -p <profile> -z "<prompt>"` runs a single prompt and prints only the
result. The `-z` spike (PH6-COD-002) verified it passes most acceptance
criteria — profile selectable, clean stdout, reliable exit status, controllable
timeout/cancellation, long/multiline prompts, full untruncated capture, and
provable profile identity — **except visibility/manageability through Herdr**:
a direct `-z` subprocess has no Herdr pane, transcript, or `agent list` entry.

Because the whole point of this transport is a visible, managed shared
workspace, `-z` is retained as a secondary/opt-in method (`--transport zexec`)
and is NOT the default. The marker method remains primary.

## Optional Graphify context phase (before dispatch)

Graphify is a shared repository-understanding capability (see
`shared/standards/agent-routing.md`). Before writing a specialist assignment,
Nova MAY run a scoped Graphify command to bound the specialist's search and
sharpen the assignment, then include the scoped result in the assignment.

This phase is optional and must never block dispatch:

1. Nova runs a scoped command — e.g. `graphify query "<question>"`,
   `graphify path "<A>" "<B>"`, `graphify explain "<concept>"`, or
   `graphify affected "<X>"` — appropriate to the specialist domain (Sentinel:
   auth paths / trust boundaries / affected components; Archivist: components a
   record must cover; Shinobi: deployment/config dependencies).
2. Nova records the EXACT command used in the assignment (the assignment
   template has a "Graphify context" section for this).
3. Nova includes only the relevant scoped output or a short summary in the
   assignment. Do NOT paste `graph.json` or the whole graph into a handoff.
4. The specialist treats the graph output as a lead, not evidence, and VERIFIES
   findings against the authoritative source files before relying on them.
5. If `graphify-out/graph.json` is missing or stale, Nova does not fail or delay
   dispatch: it discloses in the assignment that Graphify was unavailable and
   the specialist should fall back to direct repository inspection.

The dispatcher (`scripts/dispatch-specialist.sh`) is unchanged by this phase.
Graphify context is carried entirely inside the assignment prompt-file.

## Result marker protocol

- Each dispatch generates assignment-specific markers embedding the exact
  assignment ID:
  - Begin: `<<<NINJATRONICS-RESULT-BEGIN:<ID>>>>`
  - End:   `<<<NINJATRONICS-RESULT-END:<ID>>>>`
- The wrapped prompt requires the specialist to place its final handoff (per
  `shared/templates/specialist-handoff.md`) exactly once, on its own line
  immediately after the begin marker and before the end marker.
- Markers are matched ONLY when they are the sole content of a line (trimmed),
  so the echoed prompt (which references the markers inline in a sentence) does
  not satisfy extraction.
- Validation rejects, each as a distinct failure class: missing begin, missing
  end, duplicate begin, duplicate end, reversed order, mismatched assignment ID.
  Any marker failure is recorded as a FAILED transport, never a successful
  assignment.

## Identity verification

A dispatch is only trusted if the launched profile identity is confirmed. The
dispatcher records up to three independent proofs:

1. `argv == ["hermes","-p","<profile>"]` from `agent start`.
2. Live `hermes -p <profile>` in the pane's foreground process cmdline.
3. The specialist's own `PROFILE_IDENTITY: <profile>` line in its output.

An argv mismatch fails the transport with the identity-mismatch exit code.

## Exit codes (stable)

| Code | Meaning |
|---|---|
| 0   | Success |
| 2   | Usage error (bad/unknown flag, non-integer timeout, bad --transport, bad --workdir) |
| 64  | Validation error (missing/unsafe assignment ID, disallowed profile) |
| 65  | Malformed Herdr output (unparseable JSON, missing pane_id) |
| 66  | Prompt-file missing or unreadable |
| 67  | Launched profile identity mismatch |
| 68  | Result-marker failure (missing/duplicate/reversed/mismatched/empty body) |
| 69  | Herdr server not running (precheck) |
| 124 | Timeout / agent stalled during wait |
| 125 | Agent crash / abnormal termination mid-run |
| 126 | Agent start or workspace-create failure |

## Persisted artifacts (per assignment, under `shared/handoffs/<id>/`)

- `assignment.md`  — copy of the input prompt.
- `result.md`      — the full untruncated specialist response (extracted body).
- `transport.json` — transport metadata, written atomically (temp + `mv`):
  assignment ID, profile, transport method, agent name, pane/workspace/tab/
  terminal IDs, start/completion timestamps, final status, exit status, result
  and assignment artifact paths, identity-verification evidence, live-transcript
  reference, and — only on a nonzero exit — an `error` block with the Herdr
  error code, a stderr excerpt, and the agent/session state.

A successful run (exit 0) always has `error: null`. Transient codes recovered
during retries (e.g. `agent_pane_busy`) never appear on a successful run.

## Cleanup policy

- Per-agent teardown ONLY: `/quit` then `herdr pane close`. Verified via
  `herdr agent get` → `agent_not_found`.
- NEVER use `herdr session stop` or `herdr session delete` — those are
  session-wide and would kill the shared Herdr workspace.
- `--keep` skips teardown for debugging (the pane is left alive).
- Completed evidence artifacts (`assignment.md`, `transport.json`, `result.md`)
  are never deleted by the dispatcher.

## Fallback policy (delegate_task)

- The dispatcher NEVER calls `delegate_task` and NEVER hides a Herdr failure.
- On a real Herdr failure, the dispatcher records the failure (exit code,
  stderr excerpt, agent/session state, live-transcript reference) in
  `transport.json` and returns the mapped nonzero exit.
- Nova — not the script — decides whether to invoke a disclosed emergency
  fallback. Any `delegate_task` fallback must be explicitly labeled as a
  simulated specialist in both the assignment ledger and the final report,
  with: role simulated, runtime used, reason, and remaining independent review.

## Safety

- No `eval`; arguments are handled explicitly with arrays and quoting.
- Multiline prompt files are read whole and passed as a single argv value.
- The dispatcher never prints or commits `.env`, `auth.json`, profile state,
  memory databases, or transcripts containing secrets. Handoff artifacts contain
  only the assignment, the specialist result, and transport metadata.

## References

- Contract discovery: assignment PH6-CLD-001.
- Implementation + live validation: assignment PH6-COD-002.
- Operator runbook: `docs/runbooks/specialist-dispatch.md`.
