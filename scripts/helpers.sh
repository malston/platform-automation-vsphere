#!/bin/bash

__PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function setPipeline() {
  local target="${1:?}"
  local product="${2:?}"
  local env="${3:?}"

  pipeline="${product}-${env}"

  fly -t "${target}" set-pipeline \
    -p "${pipeline}" \
    -c "${__PWD}/../pipelines/${product}.yml" \
    -l "${__PWD}/../environments/${env}/params/params.yml" \
    -l "${__PWD}/../environments/${env}/creds.yml"
}

