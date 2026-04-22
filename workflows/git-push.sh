#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# FUNCTIONS
git_requires_force_push() {
  local branch
  branch=$(git branch --show-current) || return 1

  git fetch origin 2>/dev/null

  local behind ahead
  behind=$(git rev-list --count HEAD..origin/"$branch" 2>/dev/null) || return 1
  ahead=$(git rev-list --count origin/"$branch"..HEAD 2>/dev/null) || return 1

  [ "$behind" -gt 0 ] && [ "$ahead" -gt 0 ]
}

confirm_force_push() {
    confirm "Should we FORCE push modifications to upstream?"
}

# MAIN
log_info "Fetching current branch..."
current_branch=$(fetch_current_branch)

if git_requires_force_push; then
  confirm_force_push || {
    log_info "Aborted!"
    exit 1
  }

  log_and_run "Force pushing '$current_branch' branch." \
    git push --force origin $current_branch
else
  log_and_run "Pushing '$current_branch' branch." \
    git push origin $current_branch
fi

