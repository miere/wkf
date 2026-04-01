#!/usr/bin/env bash

# BOOTSTRAP
source ${WRK_DIR}/includes/defaults.sh

# MAIN
pr_url="${1:-}"

if [ -z "$pr_url" ]; then
  pr_url=$(prompt "GitHub PR URL")
fi

if [ -z "$pr_url" ]; then
  log_error "No PR URL informed. Aborting..."
  exit 1
fi

repo=$(echo "$pr_url" | sed 's|https://github.com/\([^/]*/[^/]*\)/pull/.*|\1|')
pr_number=$(echo "$pr_url" | sed 's|.*/pull/\([0-9]*\).*|\1|')

branch=$(gh api "repos/${repo}/pulls/${pr_number}" --jq '.head.ref')
head_sha=$(gh api "repos/${repo}/pulls/${pr_number}" --jq '.head.sha')

build_url=$(gh api "repos/${repo}/commits/${head_sha}/check-runs" \
  --jq '.check_runs[].output.summary // ""' \
  | grep -o 'https://[^/]*/buildConfiguration/[^"?) ]*' \
  | head -1)

if [ -z "$build_url" ]; then
  log_info "No TeamCity builds found for this PR."
  exit 0
fi

teamcity_host=$(echo "$build_url" | sed 's|https\?://\([^/]*\).*|\1|')
build_type_id=$(echo "$build_url" | sed 's|.*/buildConfiguration/\([^/?]*\).*|\1|')
token_file=$(mktemp)

log_and_run "Downloading IAP token..." \
  sh -c "gcloud auth print-identity-token --audiences='${IAP_CLIENT_ID}' --quiet > ${token_file}"

iap_token=$(cat "${token_file}"); rm -f "${token_file}"

log_and_run "Triggering build '${build_type_id}' on branch '${branch}'..." \
  curl -sf \
    -X POST "https://${teamcity_host}/app/rest/buildQueue" \
    -H "Authorization: Bearer ${iap_token}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"buildType\": {\"id\": \"${build_type_id}\"}, \"branchName\": \"${branch}\"}"
