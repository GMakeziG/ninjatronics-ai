#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

ok() {
  printf 'ok - %s\n' "$1"
  PASS=$((PASS + 1))
}

bad() {
  printf 'not ok - %s\n' "$1"
  FAIL=$((FAIL + 1))
}

assert_contains() {
  local file="$1"
  local text="$2"
  local label="$3"

  if grep -Fq -- "$text" "$file"; then
    ok "$label"
  else
    bad "$label"
  fi
}

assert_not_contains() {
  local file="$1"
  local text="$2"
  local label="$3"

  if grep -Fq -- "$text" "$file"; then
    bad "$label"
  else
    ok "$label"
  fi
}

init_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.name 'Resume Test'
  git -C "$repo" config user.email 'resume-test@example.invalid'
  printf '# Fixture\n' >"$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -q -m 'test fixture'
}

CONTROL="$TMP/control"
PROJECT="$TMP/demo"
EMPTY_PROJECT="$TMP/empty"

mkdir -p \
  "$CONTROL/scripts/harness" \
  "$CONTROL/shared/standards" \
  "$CONTROL/shared/state" \
  "$CONTROL/shared/handoffs/DEMO-ARC-001" \
  "$CONTROL/shared/handoffs/DEMO-ARC-001-R2" \
  "$CONTROL/shared/handoffs/OTHER-SEN-001" \
  "$CONTROL/vault/3_Projects" \
  "$CONTROL/vault/6_Daily"
cp "$ROOT/scripts/harness/common.sh" "$CONTROL/scripts/harness/common.sh"

init_repo "$CONTROL"
init_repo "$PROJECT"
init_repo "$EMPTY_PROJECT"

mkdir -p \
  "$PROJECT/docs/orchestration/assignments" \
  "$PROJECT/docs/orchestration/handoffs" \
  "$PROJECT/docs/planning"
printf '# Assignment\n' >"$PROJECT/docs/orchestration/assignments/DEMO-ARC-001.md"
printf '# Handoff\n' >"$PROJECT/docs/orchestration/handoffs/DEMO-ARC-001.md"
printf '# Phase Gate\n' >"$PROJECT/docs/planning/PHASE_1_GATE.md"

printf '# Ledger\n' >"$CONTROL/shared/state/assignments.md"
printf '# Routing\n' >"$CONTROL/shared/standards/agent-routing.md"
printf '# Transport\n' >"$CONTROL/shared/standards/specialist-transport.md"
printf '# Exact assignment\n' >"$CONTROL/shared/handoffs/DEMO-ARC-001/assignment.md"
printf '# Exact result\n' >"$CONTROL/shared/handoffs/DEMO-ARC-001/result.md"
printf '{}\n' >"$CONTROL/shared/handoffs/DEMO-ARC-001/transport.json"
printf '# Retry assignment\n' >"$CONTROL/shared/handoffs/DEMO-ARC-001-R2/assignment.md"
printf '# Retry result\n' >"$CONTROL/shared/handoffs/DEMO-ARC-001-R2/result.md"
printf '{}\n' >"$CONTROL/shared/handoffs/DEMO-ARC-001-R2/transport.json"
printf '# Unrelated result\n' >"$CONTROL/shared/handoffs/OTHER-SEN-001/result.md"
printf '# Demo\n' >"$CONTROL/vault/3_Projects/Demo.md"
printf '# Daily\n\nWorked on demo orchestration.\n' >"$CONTROL/vault/6_Daily/2026-08-23.md"

# shellcheck source=/dev/null
source "$CONTROL/scripts/harness/common.sh"

if [[ "$(resolve_project demo)" == "$PROJECT" && "$(resolve_project "$PROJECT")" == "$PROJECT" ]]; then
  ok 'project resolution accepts project name and absolute path'
else
  bad 'project resolution accepts project name and absolute path'
fi

PI_PROMPT="$TMP/pi.md"
HERMES_PROMPT="$TMP/hermes.md"
NORMALIZED_PI="$TMP/pi.normalized.md"
NORMALIZED_HERMES="$TMP/hermes.normalized.md"

build_resume_prompt demo "$PROJECT" pi >"$PI_PROMPT"
build_resume_prompt demo "$PROJECT" hermes >"$HERMES_PROMPT"
sed '/^Execution harness:$/ {n; s/.*/HARNESS/;}' "$PI_PROMPT" >"$NORMALIZED_PI"
sed '/^Execution harness:$/ {n; s/.*/HARNESS/;}' "$HERMES_PROMPT" >"$NORMALIZED_HERMES"

if cmp -s "$NORMALIZED_PI" "$NORMALIZED_HERMES"; then
  ok 'Pi and Hermes receive equivalent shared resume state'
else
  bad 'Pi and Hermes receive equivalent shared resume state'
fi

assert_contains "$PI_PROMPT" \
  "$CONTROL/shared/handoffs/DEMO-ARC-001/result.md" \
  'project-aware discovery includes exact assignment handoff'
assert_contains "$PI_PROMPT" \
  "$CONTROL/shared/handoffs/DEMO-ARC-001-R2/result.md" \
  'project-aware discovery includes retry-suffixed handoff'
assert_not_contains "$PI_PROMPT" \
  "$CONTROL/shared/handoffs/OTHER-SEN-001/result.md" \
  'project-aware discovery excludes unrelated handoffs'
assert_contains "$PI_PROMPT" \
  "$CONTROL/vault/3_Projects/Demo.md" \
  'matching vault project note is discovered'
assert_contains "$PI_PROMPT" \
  "$CONTROL/vault/6_Daily/2026-08-23.md" \
  'latest relevant daily note is discovered'
assert_contains "$PI_PROMPT" \
  "$CONTROL/shared/state/assignments.md" \
  'central assignment ledger is included'
assert_contains "$PI_PROMPT" \
  "$PROJECT/docs/orchestration/assignments/DEMO-ARC-001.md" \
  'project-local orchestration assignment is included'
assert_contains "$PI_PROMPT" \
  "$PROJECT/docs/planning/PHASE_1_GATE.md" \
  'project phase and gate state is included'

EMPTY_PROMPT="$TMP/empty.md"
if build_resume_prompt empty "$EMPTY_PROJECT" pi >"$EMPTY_PROMPT"; then
  ok 'missing optional orchestration, vault, daily, and graph files do not fail resume'
else
  bad 'missing optional orchestration, vault, daily, and graph files do not fail resume'
fi
assert_contains "$EMPTY_PROMPT" \
  'Project graph: absent' \
  'missing Graphify state is reported without blocking resume'

printf '%s\n' "resume tests: ${PASS} passed, ${FAIL} failed"
[[ "$FAIL" -eq 0 ]]
