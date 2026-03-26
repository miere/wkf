#!/usr/bin/env bash
claude \
   --add-dir "/tmp" \
   --permission-mode "bypassPermissions" \
   "${@}"

