# Default settings for all scripts
set -e
set -o pipefail

# FUNCTIONS
__compute_session(){
  if git_is_repository; then
    local branch=$(fetch_current_branch) # | sed 's/-/_/g'
    echo "${branch}-$$"
  else
    echo "$$"
  fi
}

# Enable TRACE mode
if [ "${TRACE}" = "true" ]; then
  set -x
  export DEBUG="true"
fi

# Load config files
CONFIG_FILES=(
  "${CUR_DIR}/.workflow.conf"
  "${HOME}/.workflow.conf"
)

for cfg in "${CONFIG_FILES[@]}"; do
  if [ -f "$cfg" ]; then
    source "$cfg"
  fi
done

# Auto-import includes
for f in "${WRK_DIR}/includes/"*.sh; do
  [ -f "$f" ] || continue
  [ "$(basename "$f")" = "defaults.sh" ] && continue
  source "$f"
done

# Must have WRK_DIR defined
if [ "${WRK_DIR}" = "" ]; then
  log_error "No WRK_DIR defined. Aborting..."
  exit 3
fi

# Must have a SESSION defined
if [ "$SESSION" = "" ]; then
  export SESSION=$(__compute_session)
fi
