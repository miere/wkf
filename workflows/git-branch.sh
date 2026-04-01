#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
current_branch=$(fetch_current_branch)

new_branch=$(
  git_list_branches |
    gum filter \
        --header="Select from existing branches" \
        --height=10 \
        --value=${current_branch} \
        --no-strict \
        --indicator=' ◉ ' --limit=1 --fuzzy-sort
)

log_and_run "Selected '$new_branch' branch." \
  git checkout $new_branch

