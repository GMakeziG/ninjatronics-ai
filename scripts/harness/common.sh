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
      cd -- "$input"
      pwd
    )
    return
  fi

  if [[ -d "${PROJECTS_ROOT}/${input}" ]]; then
    (
      cd -- "${PROJECTS_ROOT}/${input}"
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

latest_project_handoff() {
  local project_dir="$1"
  local handoff_dir="${project_dir}/docs/orchestration/handoffs"

  [[ -d "$handoff_dir" ]] || return 0

  find "$handoff_dir" \
    -maxdepth 1 \
    -type f \
    -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -n 1 |
    cut -d' ' -f2-
}

latest_shared_handoff() {
  local shared_dir="${NINJATRONICS_AI_ROOT}/shared/handoffs"

  [[ -d "$shared_dir" ]] || return 0

  find "$shared_dir" \
    -mindepth 2 \
    -maxdepth 2 \
    -type f \
    \( -name 'result.md' -o -name 'assignment.md' \) \
    -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -n 1 |
    cut -d' ' -f2-
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

  local project_handoff
  local shared_handoff

  project_handoff="$(latest_project_handoff "$project_dir" || true)"
  shared_handoff="$(latest_shared_handoff || true)"

  cat <<EOF
# Ninjatronics Project Resume

You are resuming project: ${project_name}

Project directory:
${project_dir}

Execution harness:
${harness}

Ninjatronics AI control repository:
${NINJATRONICS_AI_ROOT}

## Operating Rule

Git and repository files are authoritative project state.

The previous harness is NOT authoritative state.

Do not rediscover the entire project.

Use the smallest amount of context necessary to resume safely.

## Required Startup Sequence

Read these first if they exist:

1. ${NINJATRONICS_AI_ROOT}/AGENTS.md
2. ${NINJATRONICS_AI_ROOT}/shared/standards/orchestration.md
3. ${NINJATRONICS_AI_ROOT}/shared/standards/collaboration-workflow.md
4. ${project_dir}/README.md
5. ${project_dir}/PROJECT_STATE.md
6. ${project_dir}/MEMORY.md
7. ${project_dir}/CLAUDE.md
8. ${project_dir}/APPEND_SYSTEM.md

Do not fail merely because an optional file does not exist.

EOF

  if [[ -n "$project_handoff" ]]; then
    cat <<EOF
Latest project-local handoff discovered:

${project_handoff}

Read it before exploring additional project files.

EOF
  fi

  if [[ -n "$shared_handoff" ]]; then
    cat <<EOF
Latest Ninjatronics shared handoff discovered:

${shared_handoff}

Use it only if it is relevant to this project/current assignment.

EOF
  fi

  cat <<EOF
## Current Git State

$(git_summary "$project_dir")

## Resume Protocol

After reading the minimum required state:

- identify the current phase;
- identify the last completed milestone;
- identify the next authorized action;
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

## Context Management

Avoid automatic context compaction.

Work within the context budget defined by the project/harness instructions.

If the current task cannot safely finish within that budget:

- stop at a safe point;
- update durable project state;
- write a concise handoff;
- report the exact next action;
- ask the user to restart the harness with a fresh context.

Do not continue until context exhaustion.
EOF
}
