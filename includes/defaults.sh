# Default settings for all scripts
set -e

#
__compute_session(){
  if git_is_repository; then
    local branch=$(fetch_current_branch) # | sed 's/-/_/g'
    echo "${branch}-$$"
  else
    echo "$$"
  fi
}

if [ "${TRACE}" = "true" ]; then
  set -x
  export DEBUG="true"
fi

if [ "${WRK_DIR}" = "" ]; then
  WRK_DIR=$(dirname $0)/..
fi

for f in "${WRK_DIR}/includes/"*.sh; do
  [ -f "$f" ] || continue
  [ "$(basename "$f")" = "defaults.sh" ] && continue
  source "$f"
done

if [ "$SESSION" = "" ]; then
  export SESSION=$(__compute_session)
fi

