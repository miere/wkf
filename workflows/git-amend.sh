#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

fetch_current_branch(){
  git branch --show-current
}

select_files_to_be_commited() {
  git status -s | cut -d ' ' -f 3 | gum choose --selected='*' --no-limit --header="Select files to be commited:"
}

has_files_to_be_commited(){
  local files=$(git status -s)
  [ "$files" = "" ] && return 1 || return 0
}

# Only Git Repos are allowed
if ! git_is_repository; then
  log_error "Not a git repository... I'm unable to proceed!"
  exit 1
fi

# Warn about commiting into the main branch
current_branch=$(fetch_current_branch)

if [ "$current_branch" = "main" ]; then
  log_error "You cannot modify the 'main' branch."
fi

if has_files_to_be_commited; then
  # Select files to be commited
  log_and_run "Ensuring all modified files will be unstaged..." \
    git restore --staged .

  selected_files=$(select_files_to_be_commited)
  if [ ! "$?" = "0" ]; then
    log_error "No files selected. Aborting commit..."
    exit 0
  fi

  log_info "Staging selected files..."
  git add $selected_files
fi

# Commit dialog
git commit --amend &&
  log_info "Commit amended!" ||
  log_error "Something went wrong. =/"
