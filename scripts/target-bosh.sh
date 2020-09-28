#!/bin/bash

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

[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
 source "${__DIR}/set-om-creds.sh" ||  \
 echo "set-om-creds.sh not found"

CREDS=$(om -t $OM_TARGET --skip-ssl-validation curl --silent \
     -p /api/v0/deployed/director/credentials/bosh_commandline_credentials | \
  jq -r .credential | sed 's/bosh //g')

# this will set BOSH_CLIENT, BOSH_ENVIRONMENT, BOSH_CLIENT_SECRET, and BOSH_CA_CERT
# however, BOSH_CA_CERT will be a path that is only valid on the OM VM
array=($CREDS)
for VAR in ${array[@]}; do
  export $VAR
done


export BOSH_ALL_PROXY="ssh+socks5://ubuntu@$OM_TARGET:22?private-key=$OM_KEY"

export BOSH_CA_CERT="$(om -t $OM_TARGET --skip-ssl-validation certificate-authorities -f json | \
    jq -r '.[] | select(.active==true) | .cert_pem')"

export CREDHUB_CLIENT=$BOSH_CLIENT
export CREDHUB_SECRET=$BOSH_CLIENT_SECRET
export CREDHUB_CA_CERT=$BOSH_CA_CERT
export CREDHUB_SERVER="https://$BOSH_ENVIRONMENT:8844"
export CREDHUB_PROXY=$BOSH_ALL_PROXY

