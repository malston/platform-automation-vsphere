#!/bin/bash -e

if [ -z "${ENVIRONMENT_NAME}" ]; then
  echo "Enter an environment name (e.g. haas-420): "
  read -r ENVIRONMENT_NAME
fi

export CONCOURSE_URL="https://concourse.${ENVIRONMENT_NAME}.pez.vmware.com"

fly -t main login -c "${CONCOURSE_URL}" -u admin -k
