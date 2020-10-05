#!/bin/bash

set -ox pipefail

if [[ -z "${HARBOR_PASSWORD}" ]]; then
  echo "Enter the password for the administrator@vsphere.local account: "
  read -rs HARBOR_PASSWORD
fi

docker load -i ./images/concourse.tar
docker load -i ./images/postgres.tar
docker load -i ./images/helm.tar

export INTERNAL_REGISTRY=10.213.249.66
export PROJECT=ns1

export CONCOURSE_IMAGE_TAG=$(cat ./images/concourse.tar.name | cut -d ':' -f 2)
export POSTGRES_IMAGE_TAG=$(cat ./images/postgres.tar.name | cut -d ':' -f 2)
export HELM_IMAGE_TAG=$(cat ./images/helm.tar.name | cut -d ':' -f 2)

# docker tag SOURCE_IMAGE[:TAG] 10.213.249.66/ns1/IMAGE[:TAG]
docker tag concourse/concourse:$CONCOURSE_IMAGE_TAG $INTERNAL_REGISTRY/$PROJECT/concourse:$CONCOURSE_IMAGE_TAG
docker tag dev.registry.pivotal.io/concourse/postgres:$POSTGRES_IMAGE_TAG $INTERNAL_REGISTRY/$PROJECT/postgres:$POSTGRES_IMAGE_TAG
docker tag dev.registry.pivotal.io/concourse/helm:$HELM_IMAGE_TAG $INTERNAL_REGISTRY/$PROJECT/helm:$HELM_IMAGE_TAG

docker login "https://${INTERNAL_REGISTRY}" --username administrator@vsphere.local --password "${HARBOR_PASSWORD}"

# docker push 10.213.249.66/ns1/IMAGE[:TAG]
docker push $INTERNAL_REGISTRY/$PROJECT/concourse:$CONCOURSE_IMAGE_TAG
docker push $INTERNAL_REGISTRY/$PROJECT/postgres:$POSTGRES_IMAGE_TAG
docker push $INTERNAL_REGISTRY/$PROJECT/helm:$HELM_IMAGE_TAG