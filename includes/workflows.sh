#!/usr/bin/env bash

# WORKFLOW VARIABLES
CONFIG_DIR=${CONFIG_DIR:-${HOME}/.workflows}
WORKFLOW_DIR=${WORKFLOW_DIR:-${CONFIG_DIR}/enabled/}
LOCAL_WORKFLOW_DIR=${LOCAL_WORKFLOW_DIR:-${CUR_DIR}/scripts/local}

# FUNCTIONS
workflow_has_any_enabled() {
  local all=$(
    workflow_list_local &&
    workflow_list_enabled
  )

  [ "$all" = "" ] && return 1 || return 0
}

workflow_list_local(){
  if [ -f ${CUR_DIR}/workflows ]; then
    log_debug "Probing file ${CUR_DIR}/workflows"
    cat ${CUR_DIR}/workflows | sed '/^ *#/d;s/^ *//' | cut -d '=' -f 1
  fi
}

workflow_list_enabled(){
  log_debug "Listing ${WORKFLOW_DIR}/*.sh"
  log_debug "Listing ${LOCAL_WORKFLOW_DIR}/*.sh"
  for f in "${WRK_DIR}/workflows/always-enabled/"*sh "${WORKFLOW_DIR}/"*.sh ${LOCAL_WORKFLOW_DIR}/*.sh; do
    [ -x "$f" ] || continue
    basename "$f" .sh
  done
}

workflow_run_local() {
  local command_name="$1"
  local command_line
  local workflow_file="${CUR_DIR}/workflows"

  [ -f "$workflow_file" ] || {
    log_debug "No workflows detected. Skipping..."
    return 1
  }

  log_debug "Finding '$command_name' in the local workflows..."
  command_line=$(sed -n "/^$command_name/ s/^ *[^=]*=//p" "$workflow_file")

  if [ -n "$command_line" ]; then
    log_and_run "Running '$command_name'..." $command_line || return 2
  else
    log_debug "Could not find '$command_name' in the workflows. Skipping..."
    return 1
  fi
}

# Run workflows that are enabled
workflow_run_enabled() {
  log_debug "Finding script for command: $command"

  # candidate paths (localized)
  local scripts=(
    "${WRK_DIR}/workflows/always-enabled/${command}.sh"
    "${WORKFLOW_DIR}/${command}.sh"
    "${LOCAL_WORKFLOW_DIR}/${command}.sh"
  )

  for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
      log_debug "Triggering command '$command' with $script..."
      WRK_DIR="${WRK_DIR}" CUR_DIR="${CUR_DIR}" PWD="${CUR_DIR}" "$script"
      return
    fi
  done

  log_error "Could not execute the command '$command'."
  exit 1
}
