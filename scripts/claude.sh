#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
CLAUDE_OPTS=""

if [ ! "$SESSION" = "" ]; then
  CLAUDE_OPTS="--worktree $SESSION"
fi

claude \
   --add-dir "/tmp" \
   --permission-mode "bypassPermissions" \
   $CLAUDE_OPTS \
   "${@}"

