#!/usr/bin/env bash
# dispatch-codex.sh — Nova → Herdr → Codex transport for one assignment.
#
# Usage:
#   dispatch-codex.sh <ASSIGNMENT_ID> <PROMPT_FILE> <WORKDIR> <LABEL> [TIMEOUT_SECONDS]
#
set -euo pipefail

ASSIGNMENT_ID="$1"
PROMPT_FILE="$2"
WORKDIR="$3"
LABEL="$4"
TIMEOUT="${5:-300}"

export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/gerso/.nvm/versions/node/v24.18.0/bin:$PATH"

HANDOFF_DIR="/home/gerso/Development/ninjatronics-ai/shared/handoffs/${ASSIGNMENT_ID}"
RESULT_FILE="${HANDOFF_DIR}/result.md"

log() { printf '[dispatch:%s] %s\n' "$ASSIGNMENT_ID" "$*" >&2; }

log "Precheck: herdr status"
herdr status >/dev/null 2>&1 || { log "ERROR: herdr server not running"; exit 69; }

log "Reading prompt file: ${PROMPT_FILE}"
PROMPT="$(cat "$PROMPT_FILE")"

log "Creating workspace (label=${LABEL}, cwd=${WORKDIR})"
PANE_ID=$(herdr workspace create --label "$LABEL" --cwd "$WORKDIR" --no-focus 2>&1 \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
log "Got pane_id: ${PANE_ID}"

# Give the shell time to be ready
sleep 2

log "Confirming pane is at shell"
herdr pane process-info --pane "$PANE_ID" 2>/dev/null \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); ps=d.get("result",{}).get("process_info",{}).get("foreground_processes",[]); name=ps[0]["name"] if ps else "?"; print("foreground:", name)' >&2

log "Starting Codex agent (kind=codex, --disable plugins)"
START_OUT=$(herdr agent start "$LABEL" --kind codex --pane "$PANE_ID" --timeout 120000 -- codex --disable plugins 2>&1) || {
    log "ERROR: agent start failed: ${START_OUT}"; exit 126; }
echo "$START_OUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); r=d.get("result",{}).get("agent",{}); print("interactive_ready:", r.get("interactive_ready","?")); print("argv:", r.get("argv","?"))' >&2

# Wait for Codex to be fully ready (it may auto-update on first launch)
log "Waiting for Codex to settle (10s)"
sleep 10

log "Confirming agent still alive"
herdr pane process-info --pane "$PANE_ID" 2>/dev/null \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); ps=d.get("result",{}).get("process_info",{}).get("foreground_processes",[]); name=ps[0]["name"] if ps else "?"; print("foreground:", name)' >&2

TIMEOUT_MS=$((TIMEOUT * 1000))

# Submit the prompt without --wait first, then poll with agent wait
log "Submitting prompt (no-wait)"
herdr agent prompt "$PANE_ID" "$PROMPT" 2>&1 | python3 -c 'import sys,json; d=json.load(sys.stdin); print("submitted:", d.get("type","?"))' >&2 || true

# Small delay for the agent to pick up the prompt
sleep 3

log "Waiting for agent to reach done/idle (timeout=${TIMEOUT}s)"
WAIT_OUT=$(herdr agent wait "$PANE_ID" --until done --until idle --until blocked --timeout "$TIMEOUT_MS" 2>&1) || {
    log "WARNING: agent wait returned non-zero: ${WAIT_OUT}"; }
echo "$WAIT_OUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print("agent_status:", d.get("result",{}).get("agent",{}).get("agent_status","unknown"))' >&2 2>/dev/null || true
AGENT_STATUS=$(echo "$WAIT_OUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("result",{}).get("agent",{}).get("agent_status","unknown"))' 2>/dev/null || echo unknown)
log "agent_status: ${AGENT_STATUS}"

if [ "$AGENT_STATUS" = "blocked" ]; then
    log "BLOCKED: agent requires human intervention"
    log "PANE_ID: ${PANE_ID}"
    log "LABEL: ${LABEL}"
    log "Human approval needed at the Herdr pane. Pane left open for inspection."
    log "Approve the pending action in the existing Herdr pane, then inspect/wait on that same pane."
    printf '%s\n' "$WAIT_OUT" > "${HANDOFF_DIR}/blocked-raw.txt"
    exit 1
fi

log "Reading agent output (lines=500)"
RAW=$(herdr agent read "$PANE_ID" --source recent-unwrapped --lines 500 2>/dev/null || true)

log "Extracting between markers"
BEGIN_MARKER="<<<RESULT:${ASSIGNMENT_ID}>>>"
END_MARKER="<<<END:${ASSIGNMENT_ID}>>>"

python3 -c "
import sys
text = sys.stdin.read
b = '${BEGIN_MARKER}'
e = '${END_MARKER}'
content = text()
start = content.find(b)
end = content.find(e)
if start == -1 or end == -1 or end < start:
    print('MARKER_NOT_FOUND', file=sys.stderr)
    sys.exit(68)
extracted = content[start+len(b):end].strip()
print(extracted)
" <<< "$RAW" > "$RESULT_FILE" 2>/dev/null || {
    log "WARNING: Marker extraction failed, saving raw output"
    printf '%s\n' "$RAW" > "$RESULT_FILE"
}

log "Result saved to: ${RESULT_FILE}"
log "Word count: $(wc -w < "$RESULT_FILE")"

log "Cleanup: closing pane ${PANE_ID}"
herdr pane close "$PANE_ID" 2>/dev/null || true

log "Done."
