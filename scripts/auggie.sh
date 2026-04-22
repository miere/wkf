#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
auggie_opts=()

for arg in "$@"; do
  case "$arg" in
    --print)
      auggie_opts+=(--print -q --dont-save-session)
      ;;
    *)
      auggie_opts+=("$arg")
      ;;
  esac
done

auggie "${auggie_opts[@]}"
