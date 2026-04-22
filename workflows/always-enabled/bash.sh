#!/usr/bin/env bash

# DEFAULTS
source ${WRK_DIR}/includes/defaults.sh

# MAIN
BASH=$(which bash)
tmp_file=/tmp/workflows-$(basename $0).$$

cat <<EOF > $tmp_file
alias ls="ls --color=always"
EOF

env -i \
PS1='\[\e[90m\]❯\[\e[0m\] ' \
BASH_SILENCE_DEPRECATION_WARNING=1 \
TERM=screen-256color \
PATH="$PATH" \
HOME=/tmp \
EDITOR=$EDITOR \
  $BASH || echo

rm -f $tmp_file
exit 0
