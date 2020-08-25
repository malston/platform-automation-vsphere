#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$ENVIRONMENT_NAME" ]]; then
    echo "Enter environment name (e.g. haas-439): "
    read -r ENVIRONMENT_NAME
fi

# shellcheck source=/dev/null
[[ -f "${__DIR}/target-cp-bosh.sh" ]] &&  \
 source "${__DIR}/target-cp-bosh.sh" ||  \
 echo "target-cp-bosh.sh not found"

minio_accesskey="$(credhub get -n /p-bosh/minio/minio_accesskey -q)"
minio_secretkey="$(credhub get -n /p-bosh/minio/minio_secretkey -q)"

printf "\nMinio access key: %s" "${minio_accesskey}"
printf "\nMinio secret key: %s\n" "${minio_secretkey}"