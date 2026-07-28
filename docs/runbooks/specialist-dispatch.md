# Runbook: Dispatching a Specialist via Herdr

Operator guide for `scripts/dispatch-specialist.sh` — launching a real Hermes
specialist profile (`sentinel`, `archivist`) through Herdr, waiting, and
capturing the result. See `shared/standards/specialist-transport.md` for the
full contract and rationale.

## Prerequisites

1. Herdr server running:

   ```bash
   herdr status        # server: status: running
   ```

   If the server is not running, the dispatcher exits 69. Starting a Herdr
   server headlessly is out of scope; start/attach a Herdr session first.

2. `hermes` on PATH with the target profiles present:

   ```bash
   hermes profile list   # must include sentinel, archivist
   ```

3. `python3` available (used for JSON parsing).

## Usage

```bash
scripts/dispatch-specialist.sh \
  --assignment <ID> \
  --profile <sentinel|archivist> \
  --prompt-file <path> \
  [--timeout <SECONDS>=600] \
  [--workdir <path>=repo root] \
  [--keep] \
  [--transport <auto|marker|zexec>=auto]
```

- `--assignment` — assignment ID; safe charset `[A-Za-z0-9._-]`.
- `--profile`    — must be on the allow-list (`sentinel`, `archivist`).
- `--prompt-file`— path to the assignment prompt (markdown; multiline OK).
- `--timeout`    — max seconds to wait for the specialist (integer).
- `--workdir`    — working directory for the launched agent (default repo root).
- `--keep`       — skip teardown; leave the Herdr pane alive for debugging.
- `--transport`  — `auto` (marker, default), `marker`, or `zexec` (`hermes -z`).

## Example

```bash
cat > /tmp/review.md <<'EOF'
You are the Sentinel security specialist. Read-only review: ...
Respond using the specialist-handoff structure. Status should be "Complete".
EOF

scripts/dispatch-specialist.sh \
  --assignment PH6-SEN-010 \
  --profile sentinel \
  --prompt-file /tmp/review.md \
  --timeout 600
```

On success you get exit 0 and three artifacts under
`shared/handoffs/PH6-SEN-010/`:

- `assignment.md`  — the input prompt.
- `result.md`      — the full specialist handoff.
- `transport.json` — transport metadata + identity evidence (`error: null`).

## Reading the outcome

```bash
# exit status is authoritative
echo $?

# machine-readable transport metadata
python3 -c 'import json;d=json.load(open("shared/handoffs/<ID>/transport.json"));print(d["final_status"], d["exit_status"], d["error"])'

# the specialist response
cat shared/handoffs/<ID>/result.md
```

## Exit codes

| Code | Meaning | Operator action |
|---|---|---|
| 0   | Success | Consume `result.md`; route to next owner. |
| 2   | Usage error | Fix the flags. |
| 64  | Validation (bad ID / disallowed profile) | Correct the ID or profile. |
| 65  | Malformed Herdr output | Retry; if persistent, check Herdr health. |
| 66  | Prompt-file missing/unreadable | Fix the path. |
| 67  | Profile identity mismatch | Do NOT trust output; investigate Herdr/profile. |
| 68  | Result-marker failure | Specialist did not emit clean markers; re-dispatch or inspect the pane with `--keep`. |
| 69  | Herdr server not running | Start/attach a Herdr session. |
| 124 | Timeout / stalled | Raise `--timeout` or narrow the task. |
| 125 | Agent crash | Inspect `transport.json` error + stderr excerpt. |
| 126 | Agent start failure | Check Herdr server and pane availability. |

## Troubleshooting

- **`agent_pane_busy` retries in the log** — normal. A freshly-created pane
  needs a moment to reach a shell prompt; the dispatcher retries with backoff.
- **Marker failure (68)** — the specialist echoed the markers wrong, emitted
  them twice, or omitted the end marker. Re-run with `--keep` and inspect:

  ```bash
  herdr agent read <pane_id> --source recent-unwrapped --lines 400
  ```

  Then tear the pane down manually (`/quit`, `herdr pane close <pane_id>`).
- **Timeout (124)** — the specialist did not settle within `--timeout`. The
  agent is still torn down; raise the timeout or reduce task scope.
- **Leftover pane after `--keep`** — clean up manually:

  ```bash
  herdr pane send-text <pane_id> "/quit"
  herdr agent send-keys <pane_id> enter
  herdr pane close <pane_id>
  herdr agent get <pane_id>     # expect agent_not_found
  ```

- **Never** use `herdr session stop` / `herdr session delete` to clean up a
  single dispatch — that kills the shared Herdr session.

## Unit tests

Failure-mode unit tests (no Herdr required) live in `scripts/test-dispatch.sh`:

```bash
scripts/test-dispatch.sh    # 16 checks: arg/profile validation + marker protocol
```

## Fallback

If a real Herdr dispatch fails, the failure is recorded in `transport.json`.
The dispatcher does NOT fall back automatically. Nova decides whether to use a
disclosed `delegate_task` fallback, which must be labeled as a simulated
specialist (role, runtime, reason, remaining review) in the assignment ledger
and the final report.
