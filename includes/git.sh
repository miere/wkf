fetch_current_branch(){
  git branch --show-current
}

infer_ticket_from_branch_name(){
  fetch_current_branch | sed 's/\([A-Za-z]\{3\}-[0-9][0-9]*\).*/\1/'
}

