#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh


# GLOBAL VARIABLES
tmp_file=/tmp/workflow-$(basename $0).$$
code_review_tpl=${tmp_file}-code-review
code_review_feedback=${tmp_file}-code-review-feedback
patch_file=${tmp_file}-patch-file
commit_logs_file=${tmp_file}-commit-logs

# FUNCTIONS
generate_diff() {
  log_and_run "Computing modifications..." \
    git diff origin/main...HEAD > $patch_file
}

passed_code_review(){
  cat <<EOF >$code_review_tpl
Note: never explain your steps, output only the result.

The current branch has been modified and is ready for code review.
The just generated patch (diff) file can be found at $patch_file.
The commit logs can be found at $commit_logs_file.
Please analyse the patch file and compare with the codebase in this folder.
I want you to output either one the following words (and nothing else, no emojis
or any other words but the following 3):
- 'MINOR' - in case you found minor issues
- 'MAJOR' - in case you found major issues
- 'PASS' - if no concern has been identified

In case you output either MINOR or MAJOR, please write your concerns
in file $code_review_feedback.
EOF

  if [ ! "$1" = "" ]; then
    cat <<EOF >>$code_review_tpl
## Extra Context
Here are some extra information about the code.
$1
EOF
  fi

  concern_level=$(ai_run_template $code_review_tpl "Performing code review...")
  if [ ! "$?" = "0" ]; then
    cat <<EOF > ${tmp_file}-ai-error
$concern_level
EOF
    log_error "AI has failed. I wrote the output in the ${tmp_file}-ai-error file."
    return 2
  fi
  if [ ! "$concern_level" = "PASS" ]; then
    log_info "AI has identified '$concern_level' concerns..."
    return 1
  else
    return 0
  fi
}

proceed_anyways(){
  gum confirm \
   --no-show-help \
   --affirmative="Yes, proceed anyway" \
   --negative="Abort" \
   "Do you wish to proceed?"
}

# Only Git Repos are allowed
if [ ! -d .git ]; then
  log_error "Not a git repository... I'm unable to proceed!"
  exit 1
fi

log_success "Found valid git repository." 

# Warn about commiting into the main branch
current_branch=$(fetch_current_branch)

if [ "$current_branch" = "main" ]; then
  log_error "You cannot modify the 'main' branch."
  exit 1
fi

log_success "Not working on the 'main' branch: $current_branch"

TICKET=$(infer_ticket_from_branch_name)

if [ "$TICKET" = "" ]; then
  log_error "Could not infer the ticket from the branch name."
else
  log_success "Current branch is associated to ticket $TICKET."
fi

log_and_run "Running QA checks..." \
  ./gradlew \
    --console plain --stacktrace \
    --no-daemon --no-scan --no-watch-fs \
    detekt test 

generate_diff

context=$(prompt "Any extra info you want the AI to know?")

if ! passed_code_review "$context"; then
  if [ -f $code_review_feedback ]; then
    display_markdown_file $code_review_feedback 
    if ! proceed_anyways; then
      log_info "Aborting, as requested by the user."
      exit 0 
    fi
  else
    log_error "AI has failed to perform the Pull Request locally."
    if ! proceed_anyways; then
      log_info "Aborting, as requested by the user."
      exit 0
    fi
  fi
fi 

log_and_run "Pushing changes..." \
  git push

log_temp "Changes pushed to remote repository at the '${current_branch}' branch." 3

log_and_run "Flushing temporary files..." \
  rm ${tmp_file}*


