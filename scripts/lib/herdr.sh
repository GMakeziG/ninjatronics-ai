#!/usr/bin/env bash
# herdr.sh — sourced helpers wrapping the Herdr v0.7.5 CLI contract.
#
# Sourced by scripts/dispatch-specialist.sh. Sourcing has NO side effects.
#
# Centralizes: JSON parsing (python3), the launch/prompt/read/teardown command
# sequence discovered in Phase 1 (PH6-CLD-001), and error-code -> exit-code
# mapping. All herdr agent/pane/workspace commands emit single-line JSON on
# stdout with exit 1 on error ({"error":{"code":"..."}}); agent read / wait
# emit human text.
#
# Requires: herdr on PATH (or $HERDR_BIN), python3.

HERDR_BIN="${HERDR_BIN:-herdr}"

# ---------------------------------------------------------------------------
# JSON helpers
# ---------------------------------------------------------------------------

# hd_jget <dotted.path>   (JSON on stdin)
# Prints the scalar at path; nested dict/list is re-serialized as JSON.
# Exits nonzero if the path is missing / input is not JSON.
hd_jget() {
  python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception as e:
    sys.stderr.write("json-parse-error: %s\n" % e); sys.exit(2)
cur = d
for k in sys.argv[1].split("."):
    try:
        cur = cur[int(k)] if isinstance(cur, list) else cur[k]
    except Exception:
        sys.stderr.write("path-missing: %s\n" % sys.argv[1]); sys.exit(3)
print(cur if not isinstance(cur, (dict, list)) else json.dumps(cur))
' "$1"
}

# hd_error_code   (JSON on stdin) -> prints .error.code or empty
hd_error_code() {
  python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get("error", {}).get("code", ""))
except Exception:
    print("")
'
}

# ---------------------------------------------------------------------------
# Server / bootstrap
# ---------------------------------------------------------------------------

# hd_status_ok -> rc 0 if the Herdr server is running.
hd_status_ok() {
  "$HERDR_BIN" status 2>/dev/null | awk '
    /^server:/          { ins=1; next }
    /^[^[:space:]]/      { ins=0 }
    ins && /status:[[:space:]]*running/ { found=1 }
    END { exit(found ? 0 : 1) }'
}

# ---------------------------------------------------------------------------
# Launch
# ---------------------------------------------------------------------------

# hd_workspace_create <label> <cwd> -> emits workspace JSON (single line).
hd_workspace_create() {
  "$HERDR_BIN" workspace create --label "$1" --cwd "$2" --no-focus
}

# hd_agent_start <name> <pane_id> <profile> -> emits agent-start JSON.
# Everything after `--` becomes the launched binary's argv.
hd_agent_start() {
  "$HERDR_BIN" agent start "$1" --kind hermes --pane "$2" -- -p "$3"
}

# ---------------------------------------------------------------------------
# Prompt / wait
# ---------------------------------------------------------------------------

# hd_agent_prompt_wait <pane_id> <text> <timeout_ms>
# Submits the prompt and blocks until the agent settles (done|idle|blocked).
# Emits herdr JSON on stdout; returns herdr's exit code (0 ok, 1 on error).
hd_agent_prompt_wait() {
  "$HERDR_BIN" agent prompt "$1" "$2" \
    --wait --until done --until idle --until blocked --timeout "$3"
}

# hd_pane_wait_output <pane_id> <regex> <timeout_ms> -> rc reflects match.
hd_pane_wait_output() {
  "$HERDR_BIN" pane wait-output "$1" --regex "$2" --timeout "$3" >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# Read / inspect
# ---------------------------------------------------------------------------

# hd_agent_read <pane_id> <lines> -> rendered TUI scrollback (human text).
hd_agent_read() {
  "$HERDR_BIN" agent read "$1" --source recent-unwrapped --lines "$2"
}

# hd_process_alive <pane_id> -> rc 0 if the foreground process is `hermes`.
# rc 1 if it reverted to bash (crash/exit) or cannot be determined.
hd_process_alive() {
  "$HERDR_BIN" pane process-info --pane "$1" 2>/dev/null | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    fg = d["result"]["process_info"]["foreground_processes"]
    names = [p.get("name", "") for p in fg]
    sys.exit(0 if any("hermes" in n for n in names) else 1)
except Exception:
    sys.exit(1)
'
}

# hd_process_cmdline <pane_id> -> prints the foreground process cmdline(s).
hd_process_cmdline() {
  "$HERDR_BIN" pane process-info --pane "$1" 2>/dev/null | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    fg = d["result"]["process_info"]["foreground_processes"]
    for p in fg:
        print(p.get("cmdline") or p.get("name",""))
except Exception:
    pass
'
}

# hd_agent_gone <pane_id> -> rc 0 if the agent is gone. After a `pane close`
# the pane itself is removed, so `agent get` may report either
# `agent_not_found` or `pane_not_found`; both mean gone. Polls briefly because
# teardown can take a moment to propagate after `/quit` + `pane close`.
hd_agent_gone() {
  local out code i
  for i in 1 2 3 4 5; do
    : "$i"  # loop counter (silences SC2034)
    # `agent get` emits its error JSON on STDERR, so merge 2>&1 to capture it.
    out="$("$HERDR_BIN" agent get "$1" 2>&1)" || true
    code="$(printf '%s' "$out" | hd_error_code)"
    if [ "$code" = "agent_not_found" ] || [ "$code" = "pane_not_found" ]; then
      return 0
    fi
    sleep 1
  done
  return 1
}

# ---------------------------------------------------------------------------
# Teardown  (per-agent only; NEVER `session stop`/`session delete`)
# ---------------------------------------------------------------------------

# hd_teardown <pane_id> -> graceful /quit then close the pane. Best-effort.
hd_teardown() {
  local pane="$1"
  "$HERDR_BIN" pane send-text "$pane" "/quit" >/dev/null 2>&1 || true
  "$HERDR_BIN" agent send-keys "$pane" enter >/dev/null 2>&1 || true
  sleep 2
  # Force-stop if still alive.
  if hd_process_alive "$pane"; then
    "$HERDR_BIN" agent send-keys "$pane" C-c >/dev/null 2>&1 || true
    sleep 1
  fi
  "$HERDR_BIN" pane close "$pane" >/dev/null 2>&1 || true
}

# ---------------------------------------------------------------------------
# Error-code -> dispatcher exit-code mapping
# ---------------------------------------------------------------------------
# The dispatcher owns the exit-code constants; this maps a herdr .error.code
# string to the matching dispatcher exit code. Requires EX_* to be exported by
# the caller (dispatch-specialist.sh).
hd_map_error() {
  case "$1" in
    timeout)              echo "${EX_TIMEOUT:-124}" ;;
    agent_prompt_stalled) echo "${EX_TIMEOUT:-124}" ;;
    agent_not_found)      echo "${EX_CRASH:-125}" ;;
    *)                    echo "${EX_MALFORMED:-65}" ;;
  esac
}
