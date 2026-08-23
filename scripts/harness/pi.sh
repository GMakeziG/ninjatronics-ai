#!/usr/bin/env bash

run_pi() {
  local project_dir="$1"
  local prompt_file="$2"

  require_cmd pi

  log "Starting Pi for $(basename "$project_dir")"

  cd -- "$project_dir" || die "Unable to enter project directory: ${project_dir}"

  local prompt
  prompt="$(cat "$prompt_file")"

  exec pi \
    --approve \
    --name "Resume $(basename "$project_dir")" \
    "$prompt"
}
