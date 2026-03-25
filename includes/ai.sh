ai_run_template(){
  local tpl_file=$1; shift
  local msg=${2:-AI is thinking...}
  #log_and_run "${msg}" \
    #ai_run_interactive $tpl_file -q 
  cat $tpl_file | claude --print
}

ai_run_interactive() {
  local tpl_file=$1; shift
  #auggie --dont-save-session $@ -if $tpl_file
  cat $tpl_file | claude
}
