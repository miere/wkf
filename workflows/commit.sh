#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

fetch_current_branch(){
  git branch --show-current
}

should_create_branch(){
  gum confirm "I noticed you are commiting into 'main'. Do you want to create a branch now?"
}

create_new_branch(){
  new_branch_name=$(gum input --placeholder "Branch name")
  if [ ! "$new_branch_name" = "" ]; then
    log_and_run "Creating new branch $new_branch_name..." \
      git checkout -b $new_branch_name
  fi
}

select_files_to_be_commited() {
  git status -s | sed 's/  */ /g;s/^ //' | cut -d ' ' -f 2 |
    gum choose --selected='*' --no-limit --header="Select files to be commited:"
}

has_files_to_be_commited(){
  local files=$(git status -s)
  [ "$files" = "" ] && return 1 || return 0
}

read_ticket(){
  TICKET=$(git branch --show-current | sed 's/\([A-Za-z]\{3\}-[0-9][0-9]*\).*/\1/')
  
  if [ "$TICKET" = "" ]; then
    TICKET=$(gum input --placeholder "Ticket number: ABC-1234")
  fi

  TICKET=$(echo "$TICKET" | tr '[:lower:]' '[:upper:]')

  [ "$TICKET" = "" ] && return 1 || return 0
}

# Only Git Repos are allowed
if [ ! -d .git ]; then
  log_error "Not a git repository... I'm unable to proceed!"
  exit 1
fi

# Warn about commiting into the main branch
current_branch=$(fetch_current_branch)

if [ "$current_branch" = "main" ] && should_create_branch; then
  create_new_branch
fi

if ! read_ticket; then
  log_error "No ticket informed. Aborting..."
  exit 0
else
  log_success "Ticket: $TICKET"
fi

if ! has_files_to_be_commited; then
  log_error "No files to be commited. Aborting..."
  exit 0
fi

# Select files to be commited
log_and_run "Ensuring all modified files will be unstaged..." \
  git restore --staged .

selected_files=$(select_files_to_be_commited)
if [ ! "$?" = "0" ]; then
  log_error "No files selected. Aborting commit..."
  exit 0
fi

log_and_run "Staging selected files..." \
 git add $selected_files

# Commit dialog

SUMMARY=$(gum input --placeholder "Summary of this change")
if [ "$SUMMARY" = "" ]; then
  log_error "Summary is empty. Exiting..."
  exit 1
fi

log_success "Summary: $SUMMARY"

DESCRIPTION=$(gum write --placeholder "Details of this change")

git commit \
  -m "$SUMMARY" \
  -m "$DESCRIPTION" \
  -m "Relates-to: $TICKET" &&
     log_success "Commit: $TICKET - $SUMMARY" ||
     log_error "Failed to commit $TICKET - $SUMMARY"

