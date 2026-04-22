#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# FUNCTIONS
proceed_rebasing_current_branch(){
  confirm "You are not rebasing the main branch. Proceed?"
}

# Only Git Repos are allowed
if ! git_is_repository; then
  log_error "Not a git repository... I'm unable to proceed!"
  exit 1
fi

# Warn about commiting into the main branch
current_branch=$(fetch_current_branch)

log_info "Analysing the '$current_branch' branch..."
modified_files=$(git st)

if [ ! "$modified_files" = "" ]; then
  log_and_run "Saving changes made in the current branch..." \
    git stash -q -- .
fi

log_and_run "Reading recent modifications made on the upstream repository..." \
  git fetch --all

log_and_run "Updating from upstream..." \
  git pull origin ${current_branch} -q --rebase

log_and_run "Rebasing against 'main'..." \
  git rebase origin/main || {
    log_error "Could not proceed with the rebase. This might require manual intervention."
    log_info "Your current work is saved at $(pwd)"
    log_info "Leaving the workflow manager..."
    exit 200
  }

if [ ! "$modified_files" = "" ]; then
  log_and_run "Applying previously made changes..." \
    git stash pop -q
fi

log_info "Branch '$current_branch' has been rebased."
