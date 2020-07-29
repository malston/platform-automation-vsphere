#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OM_KEY=${1:-~/.ssh/om_rsa_key}

PROJECT="${PROJECT_NAME:-platform-automation}"
ENVIRONMENT="${ENVIRONMENT_NAME:-haas-439}"

if [[ ! -f "${OM_KEY}" ]]; then
  if [[ -n $OPSMAN_SSH_KEY ]]; then
    printenv OPSMAN_SSH_KEY > "${OM_KEY}"
  else
    echo "Ops Manager ssh key not found... fetching it from credhub"
    credhub get -n "/platform-automation/${ENVIRONMENT}/opsman_ssh_key" -k private_key > "${OM_KEY}"
  fi
  chmod 600 "${OM_KEY}"
fi

SLOT_NUMBER="$(echo $ENVIRONMENT | cut -d - -f 2)"
echo $GLOBAL_PASSWORD | pbcopy
ssh -i "${OM_KEY}" "ubuntu@ubuntu-${SLOT_NUMBER}.${ENVIRONMENT_NAME}.pez.vmware.com"
