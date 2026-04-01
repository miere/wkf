#!/usr/bin/env bash

# BOOTSTRAP
WRK_DIR=$(dirname $0)/..
source ${WRK_DIR}/includes/defaults.sh

# FUNCTIONS
function fetch_tf_token() {
  gcloud \
    --project gke-development-323204 \
    secrets versions access latest \
    --secret terraform-cloud-token | jq -r '.credentials."app.terraform.io".token'
}

read_terraform_command(){
  prompt \
     "state rm 'google_monitoring_metric_descriptor.proptrack_metrics["client/failures"]'" \
     "❯ terraform " ||
     return 1

  # convert into array
  eval "set -- $cmd"
  TERRAFORM_ARGS=("$@")
}

select_terraform_directory() {
  find . -name '.terraform' |
    sed 's/.terraform//'|
    gum choose \
      --header="We found more than one folder containing terraform scripts. Choose one:" \
      --limit=1 \
      --select-if-one
}

# Main
selected_directory=$(select_terraform_directory) 
log_success "Found terraform at $selected_directory."
cd $selected_directory

log_info "Loading terraform credentials from Google Secret Manager..."
export TF_TOKEN_app_terraform_io=$(fetch_tf_token)

while true; do
  read_terraform_command || {
     log_info "Exiting..."
     exit 0
  }

  terraform "${TERRAFORM_ARGS[@]}" || {
     log_error "Terraform command failed..."
  }
done
