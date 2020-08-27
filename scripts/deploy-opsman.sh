#! /bin/bash

set -eu

__PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# version=2.9.6

# mkdir -p ./downloads

# pushd ./downloads > /dev/null
#   pivnet login --api-token $PIVNET_TOKEN
#   pivnet download-product-files -p ops-manager -r ${version} -g "ops-manager-vsphere-*.ova"
#   pivnet logout
# popd > /dev/null


ENV_DIRECTORY="${__PWD}/../environments/${ENVIRONMENT_NAME}"

SSH_PUBLIC_KEY=$(credhub get -n "/platform-automation/${ENVIRONMENT_NAME}/opsman_ssh_key" -k public_key)
export SSH_PUBLIC_KEY

if [[ -z $SSH_PUBLIC_KEY ]]; then
  echo "Could not set the opsman public key"
  exit 1
fi

rp=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_resource_pool)
dc=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /vsphere_datacenter)
cluster=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /vsphere_cluster)

export DATASTORE=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_datastore)
export NETWORK=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_network)
export VSPHERE_HOST=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_host)
export OPSMAN_PRIVATE_IP=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_private_ip)
export OPSMAN_NETMASK=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_netmask)
export OPSMAN_GATEWAY=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_network_gateway)
export NTP=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_ntp)
export DNS=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /opsman_dns)
export OPSMAN_VM_NAME=$(bosh int ${ENV_DIRECTORY}/vars/opsman.yml --path /vm_name)
if [ -z "$rp" ]
  then
    export OM_opsman_resource_pool="/${dc}/host/${cluster}"
else
    export OM_opsman_resource_pool="/${dc}/host/${cluster}/Resources/${rp}"
fi

export GOVC_INSECURE=1
export GOVC_URL=${VSPHERE_HOST}
export GOVC_USERNAME=$VSPHERE_USER
export GOVC_PASSWORD=$VSPHERE_PASSWORD
export GOVC_DATASTORE=$DATASTORE
export GOVC_NETWORK=$NETWORK
export GOVC_RESOURCE_POOL=$OM_opsman_resource_pool

govc import.spec ./downloads/ops-manager-vsphere-*.ova \
   | jq --arg network "${NETWORK}" -r '.NetworkMapping[0].Network=$network' \
   | jq --arg ip "${OPSMAN_PRIVATE_IP}" -r '(.PropertyMapping[] | select(.Key=="ip0").Value) |=$ip' \
   | jq --arg netmask "${OPSMAN_NETMASK}" -r '(.PropertyMapping[] | select(.Key=="netmask0").Value) |=$netmask' \
   | jq --arg gateway "${OPSMAN_GATEWAY}" -r '(.PropertyMapping[] | select(.Key=="gateway").Value) |=$gateway' \
   | jq --arg dns "${DNS}" -r '(.PropertyMapping[] | select(.Key=="DNS").Value) |=$dns' \
   | jq --arg ntp "${NTP}" -r '(.PropertyMapping[] | select(.Key=="ntp_servers").Value) |=$ntp' \
   | jq --arg ssh "${SSH_PUBLIC_KEY}" -r '(.PropertyMapping[] | select(.Key=="public_ssh_key").Value) |=$ssh' \
   | jq --arg hostname "${OPSMAN_VM_NAME}" -r '(.PropertyMapping[] | select(.Key=="custom_hostname").Value) |=$hostname' \
   | jq --arg name "${OPSMAN_VM_NAME}" -r '.Name=$name' \
   | jq '.PowerOn=true' \
   > /tmp/opsman_ova.json

govc import.ova --options=/tmp/opsman_ova.json \
   "${__PWD}/../downloads/ops-manager-vsphere-*.ova" \
