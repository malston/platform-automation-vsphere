#!/bin/bash

set -eo pipefail

if [[ -z "$ENVIRONMENT_NAME" ]]; then
    echo "Enter an environment name (e.g. haas-440): "
    read -r ENVIRONMENT_NAME
fi

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "${__DIR}/target-concourse-credhub.sh" ]] &&  \
 source "${__DIR}/target-concourse-credhub.sh" ||  \
 echo "target-concourse-credhub not found"

pipelines=(deploy-pks install-dependencies)
team="main"

for pipeline in "${pipelines[@]}"; do
    PREFIX="/concourse/${team}/${pipeline}-${ENVIRONMENT_NAME}"

    credhub set -n "$PREFIX/credhub_server" -v "$CREDHUB_SERVER" -t value
    credhub set -n "$PREFIX/credhub_client" -v "$CREDHUB_CLIENT" -t value
    credhub set -n "$PREFIX/credhub_secret" -w "$CREDHUB_SECRET" -t password
    credhub set -n "$PREFIX/credhub_ca" -c "$CREDHUB_CA_CERT" -t certificate
done
