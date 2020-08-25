#!/bin/bash

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$ENVIRONMENT_NAME" ]]; then
    echo "Enter environment name (e.g. haas-439): "
    read -r ENVIRONMENT_NAME
fi

[[ -f "${__DIR}/target-cp-bosh.sh" ]] &&  \
 source "${__DIR}/target-cp-bosh.sh" ||  \
 echo "target-cp-bosh.sh not found"

# login to the BOSH director Credhub using info from bbl
echo "Connecting to Credhub on BOSH Director...."
credhub login

# read the CA certificate and client secret from the BOSH director's Credhub
echo "Reading environment details from Credhub on BOSH Director...."
SECRET=$(credhub get -n /p-bosh/concourse/concourse_to_credhub_client_secret -q)
CERT=$(credhub get -n /p-bosh/concourse/atc_tls -k ca)

# reset Credhub environment variables to point at the Concourse Credhub
unset CREDHUB_PROXY
CONCOURSE_URL=$(bosh int "${__DIR}/../../control-plane-nsxt/control-plane/vars/${ENVIRONMENT_NAME}/concourse.yml" --path /external_host)
export CREDHUB_SERVER="$CONCOURSE_URL:8844"
export CREDHUB_CLIENT=concourse_to_credhub_client
export CREDHUB_SECRET=$SECRET
export CREDHUB_CA_CERT=$CERT

echo "Connecting to Concourse Credhub..."
credhub login

