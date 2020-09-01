#!/bin/bash

set -eo pipefail

if [[ -z "${ENVIRONMENT_NAME}" ]]; then
  echo "Enter an environment name (e.g. dev): "
  read -r ENVIRONMENT_NAME
fi

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "${__DIR}/target-concourse-credhub.sh" ]] &&  \
  source "${__DIR}/target-concourse-credhub.sh" ||  \
  echo "target-concourse-credhub not found"

# credhub login \
#     --server "${CREDHUB_SERVER}" \
#     --client-name "${CREDHUB_CLIENT_NAME}" \
#     --client-secret "${CREDHUB_CLIENT_SECRET}" \
#     --ca-cert "${CREDHUB_CA_CERT}"

KEY_BITS=2048
DAYS=365

credhub generate --type "certificate" \
    --name "platform-automation/certificate_authority" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "PCFS" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --is-ca \
    --no-overwrite