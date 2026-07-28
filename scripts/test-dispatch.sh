#!/usr/bin/env bash
# test-dispatch.sh — failure-mode unit tests (no Herdr required).
#
# Exercises arg parsing, the profile allow-list, prompt-file validation, and
# the marker protocol (missing/duplicate/reversed/mismatched). Uses --transport
# forcing where a real launch would otherwise be needed; all cases here fail
# BEFORE any Herdr call, so no server is touched.
#
# Run: scripts/test-dispatch.sh   (exit 0 = all passed)
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DISPATCH="$SCRIPT_DIR/dispatch-specialist.sh"
source "$SCRIPT_DIR/lib/markers.sh"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

# Dispatcher exit-code constants (mirror of dispatch-specialist.sh).
EX_USAGE=2; EX_VALIDATION=64; EX_NOINPUT=66

ok()   { printf '  \033[32mPASS\033[0m %s\n' "$*"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }

# expect_exit <want> <label> -- <cmd...>
expect_exit() {
  local want="$1" label="$2"; shift 2; [ "$1" = "--" ] && shift
  "$@" >/dev/null 2>&1; local got=$?
  if [ "$got" -eq "$want" ]; then ok "$label (exit $got)"; else bad "$label (want $want got $got)"; fi
}

# expect_marker <want-rc> <label> <file-content>
expect_marker() {
  local want="$1" label="$2" content="$3" f="$TMP/m.$RANDOM.txt"
  printf '%s' "$content" >"$f"
  marker_validate "PH6-COD-002" "$f"; local got=$?
  if [ "$got" -eq "$want" ]; then ok "$label (rc $got)"; else bad "$label (want $want got $got)"; fi
}

echo "== A. Arg / validation failure modes =="
GOODPROMPT="$TMP/p.md"; echo "hello" >"$GOODPROMPT"
expect_exit "$EX_VALIDATION" "invalid profile rejected" -- \
  "$DISPATCH" --assignment TEST-1 --profile hacker --prompt-file "$GOODPROMPT"
expect_exit "$EX_VALIDATION" "unsafe assignment id rejected" -- \
  "$DISPATCH" --assignment 'bad id;rm' --profile sentinel --prompt-file "$GOODPROMPT"
expect_exit "$EX_VALIDATION" "empty assignment rejected" -- \
  "$DISPATCH" --profile sentinel --prompt-file "$GOODPROMPT"
expect_exit "$EX_NOINPUT" "missing prompt-file rejected" -- \
  "$DISPATCH" --assignment TEST-2 --profile sentinel --prompt-file "$TMP/nope.md"
expect_exit "$EX_NOINPUT" "no --prompt-file rejected" -- \
  "$DISPATCH" --assignment TEST-3 --profile sentinel
expect_exit "$EX_USAGE" "unknown flag rejected" -- \
  "$DISPATCH" --assignment TEST-4 --profile sentinel --prompt-file "$GOODPROMPT" --bogus
expect_exit "$EX_USAGE" "non-integer timeout rejected" -- \
  "$DISPATCH" --assignment TEST-5 --profile sentinel --prompt-file "$GOODPROMPT" --timeout abc
expect_exit "$EX_USAGE" "bad transport rejected" -- \
  "$DISPATCH" --assignment TEST-6 --profile sentinel --prompt-file "$GOODPROMPT" --transport ftp

echo "== B. Marker protocol failure modes =="
B="$(marker_begin PH6-COD-002)"; E="$(marker_end PH6-COD-002)"
expect_marker 0 "valid begin+body+end" "$B"$'\nHANDOFF BODY\n'"$E"
expect_marker 1 "missing begin"        "no begin here"$'\n'"$E"
expect_marker 2 "missing end"          "$B"$'\nbody but no end'
expect_marker 3 "duplicate begin"      "$B"$'\n'"$B"$'\nbody\n'"$E"
expect_marker 4 "duplicate end"        "$B"$'\nbody\n'"$E"$'\n'"$E"
expect_marker 5 "reversed (end<begin)" "$E"$'\nbody\n'"$B"
expect_marker 6 "mismatched id"        "$(marker_begin OTHER-ID)"$'\nbody\n'"$(marker_end OTHER-ID)"

echo "== C. Marker extraction correctness =="
XF="$TMP/x.txt"
printf 'noise banner\n%s\nLINE1\nLINE2\n%s\ntrailing noise\n' "$B" "$E" >"$XF"
BODY="$(marker_extract PH6-COD-002 "$XF")"
if [ "$BODY" = $'LINE1\nLINE2' ]; then ok "extraction strips markers+noise"; else bad "extraction body wrong: [$BODY]"; fi

echo "== D. TUI chrome scrubbing =="
CF="$TMP/chrome.txt"
printf '    Status: Complete\n    Summary: real handoff line.\n  • You'\''ve used $11.16 of your $22.00 cap\n' >"$CF"
marker_strip_chrome "$CF"
if grep -q 'cap' "$CF"; then bad "chrome cost-cap line NOT stripped"; else ok "chrome cost-cap line stripped"; fi
if grep -q 'real handoff line' "$CF"; then ok "handoff content preserved after scrub"; else bad "handoff content lost during scrub"; fi

echo
echo "==================================================="
echo "  RESULT: $PASS passed, $FAIL failed"
echo "==================================================="
[ "$FAIL" -eq 0 ]
