#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# FUNCTIONS
fetch_current_branch(){
  git branch --show-current
}

proceed_rebasing_current_branch(){
  gum confirm "You are not rebasing the main branch. Proceed?"
}

# Only Git Repos are allowed
if [ ! -d .git ]; then
  log_error "Not a git repository... I'm unable to proceed!"
  exit 1
fi

# Warn about commiting into the main branch
current_branch=$(fetch_current_branch)

if [ ! "$current_branch" = "main" ] && ! proceed_rebasing_current_branch; then
  log_info "User don't want rebase this work branch. Aborting..."
  exit 0
fi

log_info "Analysing the '$current_branch' branch..."
modified_files=$(git st)

if [ ! "$modified_files" = "" ]; then
  log_info "Saving changes made in the current branch..."
  git stash -q -- .
fi

log_info "Rebasing..."
if ! git pull -q --rebase; then
  log_error "Something went seriously wrong. We were not expecting to fail at this stage."
  exit 0
fi

if [ ! "$modified_files" = "" ]; then
  log_info "Applying previously made changes..."
  if ! git stash pop -q; then
     log_error "Conflicts were identified and we couldn't apply previously made changes. Aborting..."
     exit 0
  fi
fi

log_success "Branch '$current_branch' has been rebased."
