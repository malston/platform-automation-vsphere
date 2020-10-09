#!/bin/bash -e

OM_KEY=${1:-~/.ssh/om_rsa_key}

PROJECT="${PROJECT_NAME:-platform-automation}"
ENVIRONMENT="${ENVIRONMENT_NAME:-haas-439}"
DOMAIN="pez.vmware.com"

if [[ ! -f "${OM_KEY}" ]]; then
  if [[ -n $OPSMAN_SSH_KEY ]]; then
    printenv OPSMAN_SSH_KEY > "${OM_KEY}"
  else
    echo "Ops Manager ssh key not found... fetching it from credhub"
    credhub get -n "/${PROJECT}/${ENVIRONMENT}/opsman_ssh_key" -k private_key > "${OM_KEY}"
  fi
  chmod 600 "${OM_KEY}"
fi

SLOT_NUMBER="$(echo "$ENVIRONMENT" | cut -d - -f 2)"
echo "$GLOBAL_PASSWORD" | pbcopy
ssh -i "${OM_KEY}" "ubuntu@ubuntu-${SLOT_NUMBER}.${ENVIRONMENT_NAME}.${DOMAIN}"
