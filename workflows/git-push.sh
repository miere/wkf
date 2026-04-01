#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
log_info "Fetching current branch..."
current_branch=$(fetch_current_branch)

log_and_run "Pushing '$current_branch' branch." \
  git push origin $current_branch

