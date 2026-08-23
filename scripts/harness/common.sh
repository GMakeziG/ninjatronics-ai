#!/usr/bin/env bash

# This file is sourced by other scripts.
# Do not enable set -e here; callers own shell options.

HARNESS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd -- "${HARNESS_DIR}/.." && pwd)"
NINJATRONICS_AI_ROOT="$(cd -- "${SCRIPTS_DIR}/.." && pwd)"

PROJECTS_ROOT="${NINJATRONICS_PROJECTS_ROOT:-$(dirname "$NINJATRONICS_AI_ROOT")}"

log() {
  printf '[ninjatronics] %s\n' "$*" >&2
}

warn() {
  printf '[ninjatronics] WARNING: %s\n' "$*" >&2
}

die() {
  printf '[ninjatronics] ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 ||
    die "Required command not found: $1"
}

resolve_project() {
  local input="$1"

  if [[ -d "$input" ]]; then
    (
      cd -- "$input" || exit 1
      pwd
    )
    return
  fi

  if [[ -d "${PROJECTS_ROOT}/${input}" ]]; then
    (
      cd -- "${PROJECTS_ROOT}/${input}" || exit 1
      pwd
    )
    return
  fi

  die "Unable to locate project '${input}'. Checked:
  ${input}
  ${PROJECTS_ROOT}/${input}"
}

require_git_repo() {
  local project_dir="$1"

  git -C "$project_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "Not a Git repository: ${project_dir}"
}

project_orchestration_files() {
  local project_dir="$1"
  local orchestration_dir="${project_dir}/docs/orchestration"

  [[ -d "$orchestration_dir" ]] || return 0

  find "$orchestration_dir" \
    -maxdepth 3 \
    -type f \
    \( -path '*/assignments/*' -o -path '*/handoffs/*' \) \
    -print 2>/dev/null |
    sort
}

project_assignment_ids() {
  local project_dir="$1"
  local orchestration_dir="${project_dir}/docs/orchestration"

  [[ -d "$orchestration_dir" ]] || return 0

  find "$orchestration_dir" \
    -maxdepth 2 \
    -type f \
    \( -path '*/assignments/*.md' -o -path '*/handoffs/*.md' \) \
    -printf '%f\n' 2>/dev/null |
    sed 's/\.md$//' |
    sort -u
}

relevant_shared_handoffs() {
  local project_dir="$1"
  local shared_dir="${NINJATRONICS_AI_ROOT}/shared/handoffs"
  local assignment_id
  local handoff_dir

  [[ -d "$shared_dir" ]] || return 0

  while IFS= read -r assignment_id; do
    [[ -n "$assignment_id" ]] || continue

    while IFS= read -r handoff_dir; do
      find "$handoff_dir" \
        -maxdepth 1 \
        -type f \
        \( -name 'assignment.md' -o -name 'result.md' -o -name 'transport.json' \) \
        -print 2>/dev/null
    done < <(
      find "$shared_dir" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        \( -name "$assignment_id" -o -name "${assignment_id}-R[0-9]*" \) \
        -print 2>/dev/null
    )
  done < <(project_assignment_ids "$project_dir") |
    sort -u
}

project_phase_gate_files() {
  local project_dir="$1"

  find "$project_dir" \
    -maxdepth 4 \
    -type f \
    \( -iname '*phase*.md' -o -iname '*gate*.md' -o -iname 'project_state.md' \) \
    -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -n 12 |
    cut -d' ' -f2-
}

matching_vault_project_note() {
  local project_name="$1"
  local project_dir="${NINJATRONICS_AI_ROOT}/vault/3_Projects"
  local candidate
  local basename

  [[ -d "$project_dir" ]] || return 0

  while IFS= read -r candidate; do
    basename="$(basename "$candidate" .md)"
    if [[ "${basename,,}" == "${project_name,,}" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(find "$project_dir" -maxdepth 1 -type f -name '*.md' -print 2>/dev/null | sort)
}

latest_relevant_daily_note() {
  local project_name="$1"
  local daily_dir="${NINJATRONICS_AI_ROOT}/vault/6_Daily"

  [[ -d "$daily_dir" ]] || return 0

  grep -Fil -- "$project_name" "$daily_dir"/*.md 2>/dev/null |
    sort -r |
    head -n 1 || true
}

graphify_resume_state() {
  local project_dir="$1"
  local control_graph="${NINJATRONICS_AI_ROOT}/graphify-out/graph.json"
  local project_graph="${project_dir}/graphify-out/graph.json"
  local built_at="unknown"
  local control_head="unknown"

  if [[ -f "$control_graph" ]]; then
    if command -v python3 >/dev/null 2>&1; then
      built_at="$(python3 - "$control_graph" <<'PY'
import json
import sys

try:
    print(json.load(open(sys.argv[1], encoding="utf-8")).get("built_at_commit", "unknown"))
except (OSError, ValueError):
    print("unknown")
PY
)"
    fi
    control_head="$(git -C "$NINJATRONICS_AI_ROOT" rev-parse HEAD 2>/dev/null || printf 'unknown')"
    printf 'Ninjatronics graph: present (%s)\n' "$control_graph"
    printf 'Ninjatronics graph built_at_commit: %s\n' "$built_at"
    printf 'Ninjatronics current commit: %s\n' "$control_head"
    if [[ "$built_at" != "unknown" && "$control_head" != "unknown" && "$built_at" != "$control_head" ]]; then
      printf 'Ninjatronics graph freshness: review required (commit mismatch)\n'
    else
      printf 'Ninjatronics graph freshness: no commit mismatch detected\n'
    fi
  else
    printf 'Ninjatronics graph: absent (%s)\n' "$control_graph"
  fi

  if [[ -f "$project_graph" ]]; then
    printf 'Project graph: present (%s)\n' "$project_graph"
  else
    printf 'Project graph: absent (%s)\n' "$project_graph"
  fi
}

git_summary() {
  local project_dir="$1"

  printf 'Branch: '
  git -C "$project_dir" branch --show-current

  printf 'Latest commit: '
  git -C "$project_dir" log -1 --pretty='%h %s'

  printf 'Working tree:\n'

  local status
  status="$(git -C "$project_dir" status --short)"

  if [[ -z "$status" ]]; then
    printf 'clean\n'
  else
    printf '%s\n' "$status"
  fi
}

build_resume_prompt() {
  local project_name="$1"
  local project_dir="$2"
  local harness="$3"

  local project_orchestration
  local shared_handoffs
  local phase_gate_files
  local vault_project_note
  local daily_note
  local graphify_state

  project_orchestration="$(project_orchestration_files "$project_dir" || true)"
  shared_handoffs="$(relevant_shared_handoffs "$project_dir" || true)"
  phase_gate_files="$(project_phase_gate_files "$project_dir" || true)"
  vault_project_note="$(matching_vault_project_note "$project_name" || true)"
  daily_note="$(latest_relevant_daily_note "$project_name" || true)"
  graphify_state="$(graphify_resume_state "$project_dir" || true)"

  cat <<EOF
# Ninjatronics Project Resume

You are resuming project: ${project_name}

Project directory:
${project_dir}

Execution harness:
${harness}

Ninjatronics AI control repository:
${NINJATRONICS_AI_ROOT}

## Active Orchestrator

Pi and Nova/Hermes may both act as the active Ninjatronics orchestrator.
Unless runtime identity is explicitly relevant, existing references to "Nova"
mean the orchestrator role and apply to the active harness.

## Operating Rule

Git and repository files are authoritative project state.

The previous harness and its conversation are NOT authoritative state.

Do not rediscover the entire project.

Use the smallest amount of context necessary to resume safely.

## Required Startup Sequence

Read these first if they exist:

1. ${NINJATRONICS_AI_ROOT}/AGENTS.md
2. ${NINJATRONICS_AI_ROOT}/shared/standards/orchestration.md
3. ${NINJATRONICS_AI_ROOT}/shared/standards/agent-routing.md
4. ${NINJATRONICS_AI_ROOT}/shared/standards/collaboration-workflow.md
5. ${NINJATRONICS_AI_ROOT}/shared/standards/specialist-transport.md
6. ${NINJATRONICS_AI_ROOT}/shared/state/assignments.md
7. ${project_dir}/README.md
8. ${project_dir}/PROJECT_STATE.md
9. ${project_dir}/MEMORY.md
10. ${project_dir}/CLAUDE.md
11. ${project_dir}/APPEND_SYSTEM.md

Do not fail merely because an optional file does not exist.

EOF

  if [[ -n "$project_orchestration" ]]; then
    cat <<EOF
## Project-local orchestration records

The following assignment and handoff records are associated with this project:

${project_orchestration}

Read only the records needed to establish the current assignment and milestone.

EOF
  fi

  if [[ -n "$shared_handoffs" ]]; then
    cat <<EOF
## Matching Ninjatronics shared handoffs

These artifacts match assignment IDs found in this project's orchestration
records. Retry-suffixed attempts are included:

${shared_handoffs}

Validate result and transport evidence before relying on a handoff.

EOF
  fi

  if [[ -n "$phase_gate_files" ]]; then
    cat <<EOF
## Project phase and gate state candidates

${phase_gate_files}

Use the newest applicable gate or state record and reconcile contradictions
against Git history and authoritative project documentation.

EOF
  fi

  if [[ -n "$vault_project_note" ]]; then
    cat <<EOF
## Matching Obsidian project note

${vault_project_note}

Use this for durable project status and decisions; verify implementation facts
against the project repository.

EOF
  fi

  if [[ -n "$daily_note" ]]; then
    cat <<EOF
## Latest relevant daily note

${daily_note}

Use this as chronological context only. Durable state belongs in the project
note or repository documentation.

EOF
  fi

  cat <<EOF
## Graphify state and guidance

${graphify_state}

For codebase questions, use scoped Graphify query/path/explain commands when a
relevant graph exists. Treat graph output as a lead and verify against source.
Graphify absence or staleness never blocks work. After meaningful structural
changes, or before completing work that modified code, run \
\`graphify update .\` in the repository whose graph must be refreshed. Do not
refresh for trivial or documentation-only changes unless those files belong to
the graph corpus.

## Current Git State

$(git_summary "$project_dir")

## Resume Protocol

After reading the minimum required state:

- identify the current phase;
- identify the last completed milestone;
- identify the next authorized action;
- reconcile project-local assignment IDs with the central assignment ledger;
- inspect only files directly relevant to that action;
- do not begin implementation until the next action is clear;
- do not redo completed work;
- do not perform repository-wide exploration unless necessary.

Before making changes, give the user a concise resume report containing:

- current phase;
- last completed milestone;
- Git status;
- next authorized action;
- any blocker or discrepancy found.

Then stop for approval unless existing project instructions explicitly authorize continuation.

## Milestone Persistence Checklist

At a material milestone, the active orchestrator must reconcile these filesystem
records when applicable:

- ${NINJATRONICS_AI_ROOT}/shared/state/assignments.md
- ${NINJATRONICS_AI_ROOT}/shared/handoffs/<ID>/
- ${project_dir}/docs/orchestration/
- ${NINJATRONICS_AI_ROOT}/vault/3_Projects/<Project>.md
- ${NINJATRONICS_AI_ROOT}/vault/6_Daily/YYYY-MM-DD.md
- Graphify after meaningful structural changes

Do not fabricate missing status, evidence, review, approval, or completion.

## Context Management

Avoid automatic context compaction.

Work within the context budget defined by the project/harness instructions.

If the current task cannot safely finish within that budget:

- stop at a safe point;
- reconcile applicable durable project state;
- write a concise handoff;
- report the exact next action;
- ask the user to restart the harness with a fresh context.

Do not continue until context exhaustion.
EOF
}
