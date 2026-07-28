#!/usr/bin/env bash
# dispatch-specialist.sh — Nova -> Herdr -> Hermes specialist transport.
#
# Launches a REAL Hermes specialist profile (sentinel|archivist) through
# Herdr v0.7.5, submits a marker-wrapped assignment, waits across agent
# states, captures the FULL untruncated result, verifies profile identity,
# persists transport metadata + artifacts atomically, cleans up, and maps
# every failure to a documented exit code.
#
# This script NEVER calls delegate_task and NEVER uses eval. On a real Herdr
# failure it RECORDS the failure (code/stderr/state) and returns the mapped
# nonzero exit; Nova decides whether to invoke a disclosed fallback.
#
# Contract source: .phase1-ref/PH6-CLD-001-herdr-contract.md (PH6-CLD-001).
# Standard:        shared/standards/specialist-transport.md
# Runbook:         docs/runbooks/specialist-dispatch.md
#
# Usage:
#   scripts/dispatch-specialist.sh \
#     --assignment <ID> \
#     --profile <sentinel|archivist> \
#     --prompt-file <path> \
#     [--timeout <SECONDS>=600] \
#     [--workdir <path>=repo root] \
#     [--keep] \
#     [--transport <auto|marker|zexec>=auto]
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Exit codes (STABLE — documented in specialist-transport.md)
# ---------------------------------------------------------------------------
readonly EX_OK=0
readonly EX_USAGE=2          # bad CLI args / unknown flag
readonly EX_VALIDATION=64    # invalid assignment id or disallowed profile
readonly EX_MALFORMED=65     # malformed herdr output (unparseable JSON etc.)
readonly EX_NOINPUT=66       # prompt-file missing / unreadable
readonly EX_IDENTITY=67      # launched profile identity mismatch
readonly EX_MARKER=68        # result-marker failure (missing/dup/reversed/mismatch)
readonly EX_NOSERVER=69      # herdr server not running (precheck)
readonly EX_TIMEOUT=124      # wait exceeded timeout / agent stalled
readonly EX_CRASH=125        # agent crash / abnormal termination mid-run
readonly EX_START=126        # agent start / workspace create failure
export EX_TIMEOUT EX_CRASH EX_MALFORMED   # consumed by hd_map_error

# ---------------------------------------------------------------------------
# Locate self + libs + repo root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/markers.sh
source "$SCRIPT_DIR/lib/markers.sh"
# shellcheck source=lib/herdr.sh
source "$SCRIPT_DIR/lib/herdr.sh"

# ---------------------------------------------------------------------------
# Allow-list (single easily-extended array)
# ---------------------------------------------------------------------------
ALLOWED_PROFILES=(sentinel archivist)

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
log()  { printf '[dispatch] %s\n' "$*" >&2; }
die()  { local code="$1"; shift; log "ERROR: $*"; exit "$code"; }

now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

is_allowed_profile() {
  local p="$1" a
  for a in "${ALLOWED_PROFILES[@]}"; do [ "$a" = "$p" ] && return 0; done
  return 1
}

usage() {
  sed -n '17,27p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# ---------------------------------------------------------------------------
# Defaults + arg parsing (NO eval; explicit flag handling)
# ---------------------------------------------------------------------------
ASSIGNMENT=""; PROFILE=""; PROMPT_FILE=""
TIMEOUT_S=600; WORKDIR="$REPO_ROOT"; KEEP=0; TRANSPORT="auto"

while [ $# -gt 0 ]; do
  case "$1" in
    --assignment)  ASSIGNMENT="${2:-}"; shift 2 ;;
    --profile)     PROFILE="${2:-}"; shift 2 ;;
    --prompt-file) PROMPT_FILE="${2:-}"; shift 2 ;;
    --timeout)     TIMEOUT_S="${2:-}"; shift 2 ;;
    --workdir)     WORKDIR="${2:-}"; shift 2 ;;
    --keep)        KEEP=1; shift ;;
    --transport)   TRANSPORT="${2:-}"; shift 2 ;;
    -h|--help)     usage; exit "$EX_OK" ;;
    *)             usage; die "$EX_USAGE" "unknown argument: $1" ;;
  esac
done

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
[ -n "$ASSIGNMENT" ] || { usage; die "$EX_VALIDATION" "--assignment is required"; }
printf '%s' "$ASSIGNMENT" | grep -Eq '^[A-Za-z0-9._-]+$' \
  || die "$EX_VALIDATION" "assignment id has unsafe characters (allowed: A-Za-z0-9._-): '$ASSIGNMENT'"
[ -n "$PROFILE" ] || die "$EX_VALIDATION" "--profile is required"
is_allowed_profile "$PROFILE" \
  || die "$EX_VALIDATION" "profile '$PROFILE' is not allowed. Allowed: ${ALLOWED_PROFILES[*]}"
[ -n "$PROMPT_FILE" ] || die "$EX_NOINPUT" "--prompt-file is required"
[ -f "$PROMPT_FILE" ] && [ -r "$PROMPT_FILE" ] \
  || die "$EX_NOINPUT" "prompt-file not found or unreadable: $PROMPT_FILE"
printf '%s' "$TIMEOUT_S" | grep -Eq '^[0-9]+$' \
  || die "$EX_USAGE" "--timeout must be integer seconds: '$TIMEOUT_S'"
[ -d "$WORKDIR" ] || die "$EX_USAGE" "--workdir is not a directory: $WORKDIR"
case "$TRANSPORT" in auto|marker|zexec) ;; *) die "$EX_USAGE" "--transport must be auto|marker|zexec";; esac

# ---------------------------------------------------------------------------
# Artifact layout
# ---------------------------------------------------------------------------
HANDOFF_DIR="$REPO_ROOT/shared/handoffs/$ASSIGNMENT"
mkdir -p "$HANDOFF_DIR"
ASSIGNMENT_COPY="$HANDOFF_DIR/assignment.md"
RESULT_MD="$HANDOFF_DIR/result.md"
TRANSPORT_JSON="$HANDOFF_DIR/transport.json"
cp -- "$PROMPT_FILE" "$ASSIGNMENT_COPY"

# Scratch (auto-removed on exit).
SCRATCH="$(mktemp -d)"
RAW_BUF="$SCRATCH/raw.txt"          # rendered TUI scrollback
EXTRACT_BUF="$SCRATCH/extract.txt"  # body between markers
STDERR_BUF="$SCRATCH/stderr.txt"    # herdr stderr excerpt

# ---------------------------------------------------------------------------
# Transport metadata (accumulated, flushed atomically)
# ---------------------------------------------------------------------------
M_METHOD=""; M_AGENT=""; M_PANE=""; M_WS=""; M_TAB=""; M_TERM=""
M_START=""; M_END=""; M_STATUS="unknown"; M_IDENTITY=""
M_ERRCODE=""; M_STATE=""; M_TRANSCRIPT=""

# write_transport <exit_code>  — atomic (temp + mv).
write_transport() {
  local ex="$1" tmp
  tmp="$(mktemp "$HANDOFF_DIR/.transport.XXXXXX.json")"
  ASSIGNMENT="$ASSIGNMENT" PROFILE="$PROFILE" M_METHOD="$M_METHOD" \
  M_AGENT="$M_AGENT" M_PANE="$M_PANE" M_WS="$M_WS" M_TAB="$M_TAB" \
  M_TERM="$M_TERM" M_START="$M_START" M_END="$M_END" M_STATUS="$M_STATUS" \
  M_EXIT="$ex" M_IDENTITY="$M_IDENTITY" M_ERRCODE="$M_ERRCODE" \
  M_STATE="$M_STATE" M_TRANSCRIPT="$M_TRANSCRIPT" \
  RESULT_MD="$RESULT_MD" ASSIGNMENT_COPY="$ASSIGNMENT_COPY" \
  STDERR_EXCERPT="$(tail -c 2000 "$STDERR_BUF" 2>/dev/null || true)" \
  python3 -c '
import os, json
def g(k): return os.environ.get(k, "")
d = {
  "assignment_id": g("ASSIGNMENT"),
  "specialist_profile": g("PROFILE"),
  "transport_method": g("M_METHOD"),
  "herdr_agent_name": g("M_AGENT"),
  "pane_id": g("M_PANE"),
  "workspace_id": g("M_WS"),
  "tab_id": g("M_TAB"),
  "terminal_id": g("M_TERM"),
  "start_timestamp": g("M_START"),
  "completion_timestamp": g("M_END"),
  "final_status": g("M_STATUS"),
  "exit_status": int(g("M_EXIT") or 0),
  "result_artifact_path": g("RESULT_MD"),
  "assignment_artifact_path": g("ASSIGNMENT_COPY"),
  "identity_verification": g("M_IDENTITY"),
  "live_transcript_ref": g("M_TRANSCRIPT"),
  "error": None,
}
ec, se, st = g("M_ERRCODE"), g("STDERR_EXCERPT"), g("M_STATE")
# Only emit an error block on a genuinely failed run (nonzero exit). Transient
# codes recovered during retries (e.g. agent_pane_busy) must NOT appear on a
# successful (exit 0) transport.
if int(g("M_EXIT") or 0) != 0:
    d["error"] = {"code": ec, "stderr_excerpt": se, "agent_or_session_state": st}
print(json.dumps(d, indent=2))
' > "$tmp"
  mv -f -- "$tmp" "$TRANSPORT_JSON"
}

# ---------------------------------------------------------------------------
# Cleanup trap: teardown agent (unless --keep) + flush transport + scratch.
# ---------------------------------------------------------------------------
FINAL_EXIT="$EX_OK"
cleanup() {
  local rc=$?
  [ "$FINAL_EXIT" != "$EX_OK" ] && rc="$FINAL_EXIT"
  if [ -n "$M_PANE" ] && [ "$KEEP" -eq 0 ] && [ "$M_METHOD" = "marker" ]; then
    log "tearing down pane $M_PANE"
    hd_teardown "$M_PANE" || true
    if hd_agent_gone "$M_PANE"; then log "teardown verified: agent gone"; else log "WARN: agent may persist ($M_PANE)"; fi
  elif [ "$KEEP" -eq 1 ] && [ -n "$M_PANE" ]; then
    log "--keep set: leaving pane $M_PANE alive for debug"
  fi
  [ -z "$M_END" ] && M_END="$(now_iso)"
  write_transport "$rc" || true
  rm -rf "$SCRATCH" 2>/dev/null || true
  log "transport.json -> $TRANSPORT_JSON (exit $rc)"
}
trap cleanup EXIT

# fail <code> <state> <errcode> <msg>  — set metadata + exit.
fail() { M_STATE="$2"; M_ERRCODE="$3"; M_STATUS="failed"; FINAL_EXIT="$1"; die "$1" "$4"; }

# errcode_from <captured-stdout>  — parse .error.code from a captured stdout
# string, falling back to $STDERR_BUF. Herdr emits error JSON on STDERR for
# some subcommands (e.g. `agent start` -> agent_pane_busy), so stdout capture
# alone is empty on those failures. (Corrects a Phase-1 assumption.)
errcode_from() {
  local c; c="$(printf '%s' "$1" | hd_error_code 2>/dev/null || true)"
  [ -z "$c" ] && c="$(hd_error_code < "$STDERR_BUF" 2>/dev/null || true)"
  printf '%s' "$c"
}

# ===========================================================================
# TRANSPORT: zexec (secondary)  — hermes -p <profile> -z <prompt>
# ===========================================================================
run_zexec() {
  M_METHOD="zexec"; M_START="$(now_iso)"
  local begin end wrapped
  begin="$(marker_begin "$ASSIGNMENT")"; end="$(marker_end "$ASSIGNMENT")"
  # Wrap: require the handoff ONLY between markers, once.
  wrapped="$(cat "$PROMPT_FILE")"$'\n\n'"IMPORTANT OUTPUT PROTOCOL: State your Hermes profile name. Then emit your FINAL specialist handoff (per shared/templates/specialist-handoff.md) EXACTLY ONCE. Put a line containing only the begin marker \"${begin}\" immediately before your handoff, and a line containing only the end marker \"${end}\" immediately after it. Emit each marker line only once and put NOTHING after the end-marker line. Read-only: make no changes."
  M_TRANSCRIPT="(zexec: direct subprocess, no herdr pane)"
  log "zexec: hermes -p $PROFILE -z (timeout ${TIMEOUT_S}s)"
  set +e
  timeout "$TIMEOUT_S" hermes -p "$PROFILE" -z "$wrapped" >"$RAW_BUF" 2>"$STDERR_BUF"
  local ec=$?
  set -e
  if [ "$ec" -eq 124 ]; then fail "$EX_TIMEOUT" "zexec-timeout" "timeout" "hermes -z timed out after ${TIMEOUT_S}s"; fi
  if [ "$ec" -ne 0 ]; then fail "$EX_CRASH" "zexec-nonzero-exit($ec)" "hermes_nonzero" "hermes -z exited $ec"; fi
  # Identity: profile name must appear in output.
  if grep -qiE "profile[^A-Za-z0-9]{0,3}$PROFILE" "$RAW_BUF" || grep -qi "$PROFILE" "$RAW_BUF"; then
    M_IDENTITY="zexec: output references profile '$PROFILE'"
  else
    M_IDENTITY="zexec: profile name NOT found in output"
    fail "$EX_IDENTITY" "identity-unverified" "identity_mismatch" "could not verify profile identity in -z output"
  fi
  extract_and_finish
}

# ===========================================================================
# TRANSPORT: marker (PRIMARY)  — interactive hermes via herdr
# ===========================================================================
run_marker() {
  M_METHOD="marker"
  hd_status_ok || { M_STATUS="failed"; FINAL_EXIT="$EX_NOSERVER"; die "$EX_NOSERVER" "herdr server not running (run: herdr status)"; }

  local begin end wrapped
  begin="$(marker_begin "$ASSIGNMENT")"; end="$(marker_end "$ASSIGNMENT")"
  wrapped="$(cat "$PROMPT_FILE")"$'\n\n'"IMPORTANT OUTPUT PROTOCOL: First state your Hermes profile name on its own line as 'PROFILE_IDENTITY: <name>'. Then emit your FINAL specialist handoff (per shared/templates/specialist-handoff.md) EXACTLY ONCE. Put a line containing only the begin marker \"${begin}\" immediately before your handoff, and a line containing only the end marker \"${end}\" immediately after it. Emit each of those two marker lines only once, and put NOTHING after the end-marker line. Read-only: make NO changes to any file or system."

  # --- Launch: workspace create -> pane ---
  M_START="$(now_iso)"
  local ws_json
  ws_json="$(hd_workspace_create "ph6-$ASSIGNMENT-$PROFILE" "$WORKDIR" 2>"$STDERR_BUF")" \
    || { M_ERRCODE="$(errcode_from "$ws_json")"; fail "$EX_START" "workspace-create-failed" "${M_ERRCODE:-workspace_create}" "workspace create failed"; }
  M_PANE="$(printf '%s' "$ws_json" | hd_jget result.root_pane.pane_id 2>/dev/null || true)"
  [ -n "$M_PANE" ] || fail "$EX_MALFORMED" "no-pane-id" "malformed" "could not parse pane_id from workspace create"
  M_WS="$(printf '%s'  "$ws_json" | hd_jget result.workspace_id 2>/dev/null || printf '%s' "$M_PANE" | cut -d: -f1)"
  M_TAB="$(printf '%s' "$ws_json" | hd_jget result.root_pane.tab_id 2>/dev/null || true)"
  M_TERM="$(printf '%s' "$ws_json" | hd_jget result.root_pane.terminal_id 2>/dev/null || true)"
  M_TRANSCRIPT="herdr pane $M_PANE (workspace $M_WS, tab ${M_TAB:-n/a}, terminal ${M_TERM:-n/a})"
  log "pane=$M_PANE ws=$M_WS tab=${M_TAB:-n/a} term=${M_TERM:-n/a}"

  # --- Start agent + assert argv ---
  # Herdr agent names must be lowercase [a-z0-9_-], 1-32 chars, start with a
  # letter. Derive a valid, collision-resistant name: <profile>-<8-hex hash>.
  local id_hash
  id_hash="$(printf '%s' "$ASSIGNMENT" | (sha1sum 2>/dev/null || shasum) | cut -c1-8)"
  M_AGENT="${PROFILE}-${id_hash}"
  # A freshly-created pane may momentarily report `agent_pane_busy` before the
  # shell prompt settles. Retry a few times with a short backoff.
  local start_json ec_start attempt
  ec_start=1
  for attempt in 1 2 3 4 5 6; do
    if start_json="$(hd_agent_start "$M_AGENT" "$M_PANE" "$PROFILE" 2>"$STDERR_BUF")"; then
      ec_start=0; break
    else
      ec_start=$?
    fi
    M_ERRCODE="$(errcode_from "$start_json")"
    [ "$M_ERRCODE" = "agent_pane_busy" ] || break
    log "pane not ready yet (agent_pane_busy), retry $attempt/6"
    sleep 2
  done
  [ "$ec_start" -eq 0 ] \
    || { M_ERRCODE="$(errcode_from "$start_json")"; fail "$EX_START" "agent-start-failed" "${M_ERRCODE:-agent_start}" "agent start failed (code=${M_ERRCODE:-?})"; }
  local argv ready
  argv="$(printf '%s' "$start_json" | hd_jget result.argv 2>/dev/null || true)"
  ready="$(printf '%s' "$start_json" | hd_jget result.agent.interactive_ready 2>/dev/null || true)"
  local expect="[\"hermes\", \"-p\", \"$PROFILE\"]"
  # Normalize whitespace for comparison.
  local argv_n exp_n
  argv_n="$(printf '%s' "$argv" | tr -d ' ')"; exp_n="$(printf '%s' "$expect" | tr -d ' ')"
  if [ "$argv_n" != "$exp_n" ]; then
    M_IDENTITY="argv mismatch: got '$argv' expected '$expect'"
    fail "$EX_IDENTITY" "argv-mismatch" "identity_mismatch" "launched argv != hermes -p $PROFILE (got: $argv)"
  fi
  [ "$ready" = "True" ] || [ "$ready" = "true" ] || log "WARN: interactive_ready=$ready"
  M_IDENTITY="argv=$argv"

  # --- Submit + wait ---
  local prompt_json ec
  set +e
  prompt_json="$(hd_agent_prompt_wait "$M_PANE" "$wrapped" "$((TIMEOUT_S*1000))" 2>"$STDERR_BUF")"
  ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    M_ERRCODE="$(errcode_from "$prompt_json")"
    local mapped; mapped="$(hd_map_error "$M_ERRCODE")"
    M_STATE="prompt-error:$M_ERRCODE"
    if [ "$M_ERRCODE" = "agent_not_found" ]; then
      fail "$EX_CRASH" "$M_STATE" "$M_ERRCODE" "agent vanished during prompt (crash)"
    fi
    fail "$mapped" "$M_STATE" "$M_ERRCODE" "prompt/wait failed (code=$M_ERRCODE)"
  fi
  M_STATUS="$(printf '%s' "$prompt_json" | hd_jget result.agent.agent_status 2>/dev/null || echo unknown)"
  log "agent settled: status=$M_STATUS"
  # `blocked` is a real specialist state, not a crash — record and continue to read.
  if [ "$M_STATUS" = "blocked" ]; then log "NOTE: agent reported 'blocked' (specialist-reported state)"; fi

  # --- Confirm alive (crash detection) ---
  if ! hd_process_alive "$M_PANE"; then
    M_STATE="foreground-reverted-to-bash"
    fail "$EX_CRASH" "$M_STATE" "process_exited" "hermes foreground process gone (crash) after prompt"
  fi
  # Identity corroboration via live cmdline.
  local cmdline; cmdline="$(hd_process_cmdline "$M_PANE" 2>/dev/null || true)"
  if printf '%s' "$cmdline" | grep -q -- "-p $PROFILE"; then
    M_IDENTITY="$M_IDENTITY; cmdline confirms 'hermes -p $PROFILE'"
  fi

  # --- Wait for END marker to appear, then read the full buffer ---
  hd_pane_wait_output "$M_PANE" "$end" "15000" || log "WARN: end-marker wait-output did not match (reading anyway)"
  # Read generously; extraction handles the noise.
  hd_agent_read "$M_PANE" 2000 >"$RAW_BUF" 2>>"$STDERR_BUF" || true

  # Identity via emitted PROFILE_IDENTITY line, if present.
  if grep -qiE "PROFILE_IDENTITY:[[:space:]]*$PROFILE" "$RAW_BUF"; then
    M_IDENTITY="$M_IDENTITY; specialist declared PROFILE_IDENTITY: $PROFILE"
  fi

  extract_and_finish
}

# ---------------------------------------------------------------------------
# Shared: extract between markers, persist result, finalize.
# ---------------------------------------------------------------------------
extract_and_finish() {
  local rc
  set +e
  marker_extract "$ASSIGNMENT" "$RAW_BUF" >"$EXTRACT_BUF"
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    M_STATE="marker-failure:$(marker_reason "$rc")"
    fail "$EX_MARKER" "$M_STATE" "marker_$rc" "result-marker failure: $(marker_reason "$rc")"
  fi
  # Scrub interleaved Hermes TUI chrome (e.g. the cost-cap status bar) that can
  # render between the markers in the rendered scrollback. Handoff content is
  # untouched; this only removes unambiguous chrome lines.
  marker_strip_chrome "$EXTRACT_BUF"
  if [ ! -s "$EXTRACT_BUF" ]; then
    fail "$EX_MARKER" "marker-empty-body" "marker_empty" "markers present but body between them is empty"
  fi
  # Persist FULL result atomically (no truncation).
  local tmp; tmp="$(mktemp "$HANDOFF_DIR/.result.XXXXXX.md")"
  cat "$EXTRACT_BUF" >"$tmp"
  mv -f -- "$tmp" "$RESULT_MD"
  M_END="$(now_iso)"
  [ "$M_STATUS" = "unknown" ] && M_STATUS="done"
  [ "$M_STATUS" = "idle" ] && M_STATUS="done"
  log "result -> $RESULT_MD ($(wc -c <"$RESULT_MD") bytes)"
  FINAL_EXIT="$EX_OK"
}

# ===========================================================================
# Transport selection
# ===========================================================================
# Primary = marker (always works if server up). zexec is secondary; `auto`
# uses marker. Force zexec only via --transport zexec.
case "$TRANSPORT" in
  marker) run_marker ;;
  zexec)  run_zexec ;;
  auto)   run_marker ;;
esac

exit "$FINAL_EXIT"
