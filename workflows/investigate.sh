#!/usr/bin/env bash

# BOOTSTRAP
WRK_DIR=$(dirname $0)/..
source ${WRK_DIR}/includes/defaults.sh

# FUNCTIONS

# GLOBALS
tmp_file=/tmp/$(basename $0).$$

# MAIN
jira_ticket=$(prompt "ARC-1234" "Jira ticket to be investigated: ")
log_info "Ticket to be investigated: $jira_ticket"

context=$(prompt "Give me some context: ")
log_info "$context"

instructions=$(prompt "AI should: ")
log_info "$instructions"

cat <<EOF > $tmp_file
I have this Jira support ticket. https://vmxproperty.atlassian.net/browse/${jira_ticket}
I want you to read it so you can get more awareness of the issue.
For all the interactions we are going to have, do not print any other output, like intros or conclusions, nor reasoning explanations. I want solely your answers to my questions.

## Context
${context}

## Instructions
$instructions
EOF

log_temp "Starting Auggie..."
auggie --instruction-file $tmp_file || log_error "Something went wrong. =/"

rm -f $tmp_file
