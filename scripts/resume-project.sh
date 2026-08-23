#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=harness/common.sh
source "${SCRIPT_DIR}/harness/common.sh"

usage() {
  cat <<'EOF'
Usage:
  resume-project.sh <project> --harness <pi|hermes>
  resume-project.sh <project-path> --harness <pi|hermes>

Examples:
  ./scripts/resume-project.sh zaifu --harness pi
  ./scripts/resume-project.sh zaifu --harness hermes
  ./scripts/resume-project.sh /home/gerso/Development/zaifu --harness pi

Environment:
  NINJATRONICS_PROJECTS_ROOT
      Optional directory containing project repositories.
      Defaults to the parent directory of ninjatronics-ai.
EOF
}

PROJECT_INPUT=""
HARNESS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --harness)
      [[ $# -ge 2 ]] || die "--harness requires a value"
      HARNESS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      if [[ -n "$PROJECT_INPUT" ]]; then
        die "Only one project may be specified"
      fi
      PROJECT_INPUT="$1"
      shift
      ;;
  esac
done

[[ -n "$PROJECT_INPUT" ]] || {
  usage
  exit 1
}

[[ -n "$HARNESS" ]] || die "Specify --harness pi or --harness hermes"

case "$HARNESS" in
  pi|hermes) ;;
  *) die "Unsupported harness: $HARNESS" ;;
esac

PROJECT_DIR="$(resolve_project "$PROJECT_INPUT")"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

log "Project: ${PROJECT_NAME}"
log "Path:    ${PROJECT_DIR}"
log "Harness: ${HARNESS}"

require_git_repo "$PROJECT_DIR"

PROMPT_FILE="$(mktemp --tmpdir "ninjatronics-${PROJECT_NAME}-${HARNESS}.XXXXXX.md")"
trap 'rm -f "$PROMPT_FILE"' EXIT

build_resume_prompt \
  "$PROJECT_NAME" \
  "$PROJECT_DIR" \
  "$HARNESS" \
  > "$PROMPT_FILE"

log "Resume context prepared: ${PROMPT_FILE}"

case "$HARNESS" in
  pi)
    # shellcheck source=harness/pi.sh
    source "${SCRIPT_DIR}/harness/pi.sh"
    run_pi "$PROJECT_DIR" "$PROMPT_FILE"
    ;;
  hermes)
    # shellcheck source=harness/hermes.sh
    source "${SCRIPT_DIR}/harness/hermes.sh"
    run_hermes "$PROJECT_DIR" "$PROMPT_FILE"
    ;;
esac
