#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# FUNCTIONS
proceed_rebasing_current_branch(){
  confirm "You are not rebasing the main branch. Proceed?"
}

# Only Git Repos are allowed
if [ ! -d .git ]; then
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

log_and_run "Rebasing..." \
  git pull -q --rebase

if [ ! "$modified_files" = "" ]; then
  log_and_run "Applying previously made changes..." \
    git stash pop -q
fi

log_info "Branch '$current_branch' has been rebased."
