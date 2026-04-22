CLAUDE="${WRK_DIR}/scripts/claude.sh"
AUGGIE="${WRK_DIR}/scripts/auggie.sh"
AI_CMD="${AUGGIE}"

ai_run_template(){
  local tpl_file=$1; shift
  local msg=${1:-AI is thinking...}
  log_info "$msg"
  cat $tpl_file | $AI_CMD --print
}

ai_run_interactive() {
  local tpl_file=$1; shift
  cat $tpl_file | $AI_CMD
}
