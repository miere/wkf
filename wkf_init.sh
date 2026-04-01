#!/usr/bin/env bash
cd $(dirname $0)
export WRK_DIR=$(pwd)

# BOOTSTRAP

# FUNCTIONS
list_all_eligible_workflows(){
  find workflows | sed '/always-enabled/d' | while read file; do
    [ -d $file ] && continue
    echo $file
  done
}

# MAIN
source ${WRK_DIR}/includes/defaults.sh
log_success "Reading default configuration..."

log_and_run "Creating ${WORKFLOW_DIR} directory..." \
  mkdir -p ${WORKFLOW_DIR}

log_info "Looking for workflows..."
selected=$(
   list_all_eligible_workflows |
    gum choose \
      --padding="1 2" \
      --header="Which workflows should we enable?" \
      --selected="*" --no-limit
)

for workflow in $selected; do
  file_name=$(basename $workflow)
  log_and_run "Enabling ${workflow}" \
    ln -s ${WRK_DIR}/$workflow ${WORKFLOW_DIR}/$file_name
done

log_info "Finished."