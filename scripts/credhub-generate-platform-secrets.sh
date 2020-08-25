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

PROJECT="${PROJECT:-platform-automation}"
PREFIX="/${PROJECT}/${ENVIRONMENT_NAME}"

if [[ -z "${PIVNET_TOKEN}" ]]; then
  echo "Enter a pivnet token that has platform-automation access: "
  read -s PIVNET_TOKEN
fi

if [[ -z "${HARBOR_ADMIN_PASSWORD}" ]]; then
  echo "Enter the password for the harbor administrator account: "
  read -s HARBOR_ADMIN_PASSWORD
fi

if [[ -z "${VCENTER_USERNAME}" ]]; then
  echo "Enter the username for the vcenter administrator account: "
  read -r VCENTER_USERNAME
fi

if [[ -z "${VCENTER_PASSWORD}" ]]; then
  echo "Enter the password for the vcenter administrator account: "
  read -s VCENTER_PASSWORD
fi

if [[ -z "${OPSMAN_USERNAME}" ]]; then
  echo "Enter a username for the opsman administrator account: "
  read -r OPSMAN_USERNAME
fi

if [[ -z "${OPSMAN_PASSWORD}" ]]; then
  echo "Enter a password for the opsman administrator account: "
  read -s OPSMAN_PASSWORD
fi

if [[ -z "${OPSMAN_DECRYPTION_PASSPHRASE}" ]]; then
  echo "Enter a decryption passphrase to unlock the opsman ui: "
  read -s OPSMAN_DECRYPTION_PASSPHRASE
fi

if [[ -z "${OPSMAN_HOSTNAME}" ]]; then
  echo "Enter the FQDN for the opsman dns record: (default: opsman.${ENVIRONMENT_NAME}.pez.pivotal.io) "
  read -r OPSMAN_HOSTNAME
  if [[ -z "${OPSMAN_HOSTNAME}" ]]; then
    OPSMAN_HOSTNAME="opsman.${ENVIRONMENT_NAME}.pez.pivotal.io"
  fi
fi

if [[ -z "${OPSMAN_SSH_PASSWORD}" ]]; then
  echo "Enter a password to ssh into opsman vm: "
  read -s OPSMAN_SSH_PASSWORD
fi

if [[ -z "${NSX_ADMIN_PASSWORD}" ]]; then
  echo "Enter nsxt admin password: "
  read -s NSX_ADMIN_PASSWORD
fi

if [[ -z "${NSX_AUDIT_PASSWORD}" ]]; then
  echo "Enter nsxt audit password: "
  read -s NSX_AUDIT_PASSWORD
fi

if [[ -z "${NSX_ROOT_PASSWORD}" ]]; then
  echo "Enter nsxt root password: "
  read -s NSX_ROOT_PASSWORD
fi

credhub set -n "$PREFIX/opsman_hostname" --value "${OPSMAN_HOSTNAME}" -t value
credhub set -n "$PREFIX/opsman_username" --value "${OPSMAN_USERNAME}" -t value
credhub set -n "$PREFIX/opsman_password" --password "${OPSMAN_PASSWORD}" -t password
# credhub set -n "$PREFIX/opsman_ssh_password" --password "${OPSMAN_SSH_PASSWORD}" -t password
credhub generate -n "$PREFIX/opsman_ssh_key" -t ssh
credhub set -n "$PREFIX/opsman_decryption_passphrase" --password "${OPSMAN_DECRYPTION_PASSPHRASE}" -t password
credhub set -n "$PREFIX/vcenter_username" --value "${VCENTER_USERNAME}" -t value
credhub set -n "$PREFIX/vcenter_password" --password "${VCENTER_PASSWORD}" -t password
credhub set -n "$PREFIX/harbor_admin_password" --password "${HARBOR_ADMIN_PASSWORD}" -t password
credhub set -n "$PREFIX/pivnet_token" --password "${PIVNET_TOKEN}" -t password
credhub set -n "$PREFIX/nsx_admin_password" --password "${NSX_ADMIN_PASSWORD}" -t password
credhub set -n "$PREFIX/nsx_audit_password" --password "${NSX_AUDIT_PASSWORD}" -t password
credhub set -n "$PREFIX/nsx_root_password" --password "${NSX_ROOT_PASSWORD}" -t password
