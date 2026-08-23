#!/usr/bin/env bash

run_hermes() {
  local project_dir="$1"
  local prompt_file="$2"

  require_cmd nova

  log "Starting Nova/Hermes for $(basename "$project_dir")"

  exec nova chat \
    --in "$project_dir" \
    --query-file "$prompt_file"
}
