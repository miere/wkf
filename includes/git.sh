# GLOBALS
GIT_DEFAULT_WORKTREE_PATH=${GIT_DEFAULT_WORKTREE_PATH:-.claude/worktrees}

# FUNCTIONS
fetch_current_branch(){
  if ! git_is_repository; then
    echo "not a give repo"
  else
    git branch --show-current
  fi
}

infer_ticket_from_branch_name(){
  fetch_current_branch | sed 's/\([A-Za-z]\{3\}-[0-9][0-9]*\).*/\1/'
}

git_is_repository(){
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || git rev-parse --is-bare-repository >/dev/null 2>&1
}

git_has_files_to_be_commited(){
  local files=$(git status -s)
  [ "$files" = "" ] && return 1 || return 0
}

git_list_branches(){
  git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
    | sed 's|^[^/]*/||' \
    | sort -u
}

git_has_uncleaned_worktrees(){
  local found=$(git_list_worktrees)
  [ "$found" = "" ] && return 1 || return 0
}

git_list_worktrees(){
  [ -d ${GIT_DEFAULT_WORKTREE_PATH} ] && ls ${GIT_DEFAULT_WORKTREE_PATH} | while read file_name; do
    echo "${GIT_DEFAULT_WORKTREE_PATH}/$file_name"
  done
}

git_choose_worktree(){
  git_list_worktrees | gum choose \
    --header="The following worktrees are still active. Which one should I use?" \
    --cursor="❯ " \
    --select-if-one 
}

git_create_new_worktree() {
  local ticket=$(prompt "What ticket are you working on?") || return 1
  local worktree="${ticket}-${SESSION}"
  log_and_run "Creating worktree $worktree" \
    ${WRK_DIR}/scripts/git-create-worktree.sh "${GIT_DEFAULT_WORKTREE_PATH}/${worktree}" "$worktree" || return 1
  echo "${GIT_DEFAULT_WORKTREE_PATH}/$worktree"
}

git_reallocate_worktree(){
    local worktree="$1"
    log_and_run "Creating worktree $worktree" \
      ${WRK_DIR}/scripts/git-create-worktree.sh "${GIT_DEFAULT_WORKTREE_PATH}/${worktree}" "$worktree" || return 1
    echo "${GIT_DEFAULT_WORKTREE_PATH}/$worktree"
}

git_get_top_level_dir() {
  git rev-parse --show-toplevel
}
