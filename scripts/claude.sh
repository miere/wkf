#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
claude \
   --add-dir "/tmp" \
   --permission-mode "bypassPermissions" \
   "${@}"

