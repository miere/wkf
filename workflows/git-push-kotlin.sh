#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

fetch_current_branch(){
  git branch --show-current
}

# Only Git Repos are allowed
if [ ! -d .git ]; then
  log_error "Not a git repository... I'm unable to proceed!"
  exit 1
fi

# Warn about commiting into the main branch
current_branch=$(fetch_current_branch)

if [ "$current_branch" = "main" ]; then
  log_error "You cannot modify the 'main' branch."
fi

# Commit dialog
log_and_run "Running QA checks..." \
  ./gradlew \
    --console plain --stacktrace \
    --no-daemon --no-scan --no-watch-fs \
    detekt test integrationTest

log_and_run "Pushing changes..." \
  git push

log_temp "Changes pushed to remote repository at the '${current_branch}' branch." 3