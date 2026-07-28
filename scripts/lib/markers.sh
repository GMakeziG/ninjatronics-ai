#!/usr/bin/env bash
# markers.sh — assignment-specific result marker protocol.
#
# Sourced by scripts/dispatch-specialist.sh. Sourcing has NO side effects.
#
# Purpose: a specialist's final handoff must be emitted exactly once, between
# a BEGIN and END marker that both embed the exact assignment ID. This makes
# it impossible for a stale answer, another assignment's answer, or surrounding
# TUI/banner noise to satisfy extraction.
#
# Marker form:
#   <<<NINJATRONICS-RESULT-BEGIN:<ID>>>>
#   <<<NINJATRONICS-RESULT-END:<ID>>>>
#
# Validation rejects: missing begin, missing end, duplicate begin, duplicate
# end, reversed order (end before begin), and mismatched assignment ID.

MARKER_PREFIX="NINJATRONICS-RESULT"

# marker_begin <ID> -> prints the assignment-specific begin marker.
marker_begin() { printf '<<<%s-BEGIN:%s>>>' "$MARKER_PREFIX" "$1"; }

# marker_end <ID> -> prints the assignment-specific end marker.
marker_end() { printf '<<<%s-END:%s>>>' "$MARKER_PREFIX" "$1"; }

# marker_validate <ID> <FILE>
# Markers are matched ONLY when they are the sole content of a line (ignoring
# surrounding whitespace). This makes extraction robust against the prompt
# echo, where the markers appear INLINE inside instruction sentences and must
# not be counted. Returns a distinct code per failure class:
#   0 ok
#   1 missing begin marker
#   2 missing end marker
#   3 duplicate begin marker
#   4 duplicate end marker
#   5 reversed markers (end appears before begin)
#   6 mismatched assignment id (a marker of a DIFFERENT id is present, ours is not)
marker_validate() {
  local id="$1" file="$2"
  local b e nb ne gb ge
  b="$(marker_begin "$id")"
  e="$(marker_end "$id")"

  # Exact-ID, whole-line (trimmed) counts.
  nb=$(_marker_count_exact "$b" "$file")
  ne=$(_marker_count_exact "$e" "$file")
  # Any-ID, whole-line counts (to distinguish "mismatched" from "missing").
  gb=$(_marker_count_re "<<<${MARKER_PREFIX}-BEGIN:[^>]+>>>" "$file")
  ge=$(_marker_count_re "<<<${MARKER_PREFIX}-END:[^>]+>>>" "$file")

  # A marker exists but not for OUR id -> mismatched.
  if { [ "$nb" -eq 0 ] && [ "$gb" -gt 0 ]; } || { [ "$ne" -eq 0 ] && [ "$ge" -gt 0 ]; }; then
    return 6
  fi
  [ "$nb" -eq 0 ] && return 1
  [ "$ne" -eq 0 ] && return 2
  [ "$nb" -gt 1 ] && return 3
  [ "$ne" -gt 1 ] && return 4

  local lb le
  lb=$(_marker_line_exact "$b" "$file")
  le=$(_marker_line_exact "$e" "$file")
  [ "$le" -lt "$lb" ] && return 5
  return 0
}

# _marker_count_exact <marker> <file> -> count of lines equal to marker (trimmed).
_marker_count_exact() {
  awk -v m="$1" 'BEGIN{c=0} {t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t); if(t==m)c++} END{print c+0}' "$2" 2>/dev/null || echo 0
}
# _marker_count_re <regex> <file> -> count of lines that are ONLY a marker (trimmed).
_marker_count_re() {
  awk -v re="$1" 'BEGIN{c=0} {t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t); if(t ~ ("^" re "$"))c++} END{print c+0}' "$2" 2>/dev/null || echo 0
}
# _marker_line_exact <marker> <file> -> 1-based line number of first exact (trimmed) match.
_marker_line_exact() {
  awk -v m="$1" '{t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t); if(t==m){print NR; exit}}' "$2" 2>/dev/null
}

# marker_extract <ID> <FILE>
# On success (rc 0) prints the body strictly BETWEEN the begin and end markers
# (marker lines themselves excluded) to stdout. On failure returns the same
# code as marker_validate and prints nothing.
marker_extract() {
  local id="$1" file="$2" rc
  marker_validate "$id" "$file"; rc=$?
  [ "$rc" -ne 0 ] && return "$rc"
  local b e
  b="$(marker_begin "$id")"
  e="$(marker_end "$id")"
  awk -v b="$b" -v e="$e" '
    { t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t) }
    t==b { grab=1; next }
    t==e { grab=0 }
    grab { print }
  ' "$file"
  return 0
}

# marker_strip_chrome <FILE>
# Removes interleaved Hermes TUI chrome from an already-extracted body, in
# place. The interactive TUI can render a status/cost bar whose line lands
# between the BEGIN/END markers in the rendered scrollback (observed:
# "• You've used $X of your $Y cap"). That chrome is not part of the
# specialist handoff and must not pollute the persisted evidence artifact.
# Only unambiguous chrome lines are dropped; handoff content is untouched.
marker_strip_chrome() {
  local file="$1" tmp
  tmp="$(mktemp)"
  # Drop whole lines (trimmed) that are the Hermes cost-cap status bar.
  grep -vE "^[[:space:]]*(•|\*)?[[:space:]]*You'?ve used \\\$[0-9].*cap[[:space:]]*$" \
    "$file" >"$tmp" 2>/dev/null || cp -- "$file" "$tmp"
  mv -f -- "$tmp" "$file"
}

# marker_reason <CODE> -> human-readable reason for a marker_validate code.
marker_reason() {
  case "$1" in
    0) echo "ok" ;;
    1) echo "missing begin marker" ;;
    2) echo "missing end marker" ;;
    3) echo "duplicate begin marker" ;;
    4) echo "duplicate end marker" ;;
    5) echo "reversed markers (end before begin)" ;;
    6) echo "mismatched assignment id in marker" ;;
    *) echo "unknown marker error ($1)" ;;
  esac
}
