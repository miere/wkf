#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
if confirm "Did you finish with the current ticket? If so, we will purge the current worktree."; then
  current_branch=$(fetch_current_branch)
  top=$(git_get_top_level_dir)
  cd "$(dirname "$top")"

  log_and_run "Purging worktree..." \
    git worktree remove --force "$top"

  log_and_run "Deleting local branch '${current_branch}'..." \
    git branch -D ${current_branch}
else
  log_info "Not purging the current worktree."
fi

# special exit code to gracefully terminate `wkf`.
exit 200