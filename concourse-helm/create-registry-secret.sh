#!/bin/bash

set -o pipefail

DOCKER_SERVER=10.213.249.66
DOCKER_USERNAME="administrator@vsphere.local"
NAMESPACE=default

if [[ -z "${DOCKER_PASSWORD}" ]]; then
  echo -n "Enter the password for the $DOCKER_USERNAME account: "
  read -rs DOCKER_PASSWORD
fi

kubectl create secret docker-registry regcred \
    --docker-server="${DOCKER_SERVER}" \
    --docker-username="${DOCKER_USERNAME}" \
    --docker-password="${DOCKER_PASSWORD}" \
    --namespace=kube-system

kubectl create secret docker-registry regcred \
    --docker-server="${DOCKER_SERVER}" \
    --docker-username="${DOCKER_USERNAME}" \
    --docker-password="${DOCKER_PASSWORD}" \
    --namespace=$NAMESPACE

kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode