#!/usr/bin/env bash
set -e

# This script only exists because we want to hide the output
# messages printed from `git worktree` command. It prints things
# to both stdout and stderr.

WORKTREE_PATH=${1:?Missing path}
BRANCH=${2:?Missing branch}

git worktree add "$WORKTREE_PATH" -b "$BRANCH" 1>/dev/null 2>&1 || exit 1
