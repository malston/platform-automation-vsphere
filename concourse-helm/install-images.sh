#!/bin/bash

set -ox pipefail

# if [[ -z "${DOCKER_PASSWORD}" ]]; then
#   echo "Enter the password for the malston account: "
#   read -rs DOCKER_PASSWORD
# fi

# docker load -i ./images/concourse.tar
# docker load -i ./images/postgres.tar
# docker load -i ./images/helm.tar

export CONCOURSE_IMAGE_TAG=$(cat ./images/concourse.tar.name | cut -d ':' -f 2)
export POSTGRES_IMAGE_TAG=$(cat ./images/postgres.tar.name | cut -d ':' -f 2)
export HELM_IMAGE_TAG=$(cat ./images/helm.tar.name | cut -d ':' -f 2)

USERNAME=malston

docker tag concourse/concourse:$CONCOURSE_IMAGE_TAG $USERNAME/concourse:$CONCOURSE_IMAGE_TAG
docker tag dev.registry.pivotal.io/concourse/postgres:$POSTGRES_IMAGE_TAG $USERNAME/postgres:$POSTGRES_IMAGE_TAG
docker tag dev.registry.pivotal.io/concourse/helm:$HELM_IMAGE_TAG $USERNAME/helm:$HELM_IMAGE_TAG

docker login

docker push $USERNAME/concourse:$CONCOURSE_IMAGE_TAG
docker push $USERNAME/postgres:$POSTGRES_IMAGE_TAG
docker push $USERNAME/helm:$HELM_IMAGE_TAG