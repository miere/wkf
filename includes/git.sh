fetch_current_branch(){
  if [ ! -d .git ]; then
    echo "not a give repo"
  else
    git branch --show-current
  fi
}

infer_ticket_from_branch_name(){
  fetch_current_branch | sed 's/\([A-Za-z]\{3\}-[0-9][0-9]*\).*/\1/'
}

