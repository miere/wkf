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
  prompt "state rm 'google_monitoring_metric_descriptor.proptrack_metrics["client/failures"]'" "terraform " || exit 2
}

# Main
if [ ! -d .terraform ]; then
  confirm "This folder is not a terraform folder. Do still you wish to proceed?" || exit 1
fi

log_info "Loading terraform credentials from Google Secret Manager..."
export TF_TOKEN_app_terraform_io=$(fetch_tf_token)

while true; do
  cmd=$(read_terraform_command)
  if [ ! "$?" = "0" ]; then
     log_info "Exiting..."
     exit 0
  fi
  echo terraform $cmd || (
     log_error "Terraform command failed..." &&
     echo
  ) 
done
