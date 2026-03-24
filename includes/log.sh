
log_and_run() {
  local title="$1"; shift
  gum spin --spinner pulse --title "$title" --show-error -- "$@" && \
    log_success "$title"
}

log_temp(){
  local title="$1"; shift
  gum spin --spinner pulse --title "$title" -- sleep ${1:-2}
}

log_info(){
  gum log --message.foreground=8 "• $@"
}

log_success(){
  gum spin --spinner pulse --title "$@" -- sleep 0.7
  gum log --message.foreground=10 "✓ $@"
}

log_error(){
  gum spin --spinner pulse --title "$@" -- sleep 2
  gum log --message.foreground=9 "! $@"
}

prompt(){
  local extra_opts=(--padding="0 0")
  if [ -n "$2" ]; then
    extra_opts+=("--prompt=$2")
  fi
  if [ -n "$3" ]; then
    extra_opts+=("--prompt.foreground=$3")
  fi
  gum input --placeholder="$1" "${extra_opts[@]}"
}

long_prompt(){
  local extra_opts=(--width=70)
  if [ -n "$1" ]; then
    extra_opts+=("--placeholder=$1")
  fi
  gum write "${extra_opts[@]}" 
}

confirm(){
  gum confirm --padding="1 2" "$@"
}

display_markdown() {
  gum format
}

display_markdown_file() {
  cat $1 | display_markdown 
}

display_file() {
  cat $1 | gum pager
}
