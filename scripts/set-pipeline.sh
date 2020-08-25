#!/bin/bash

set -eo pipefail

CONCOURSE_TARGET="${CONCOURSE_TARGET:-main}"
PRODUCT="${PRODUCT:-pks}"
ENVIRONMENT="${ENVIRONMENT_NAME:-haas-439}"

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
[[ -f "${__DIR}/helpers.sh" ]] &&  \
 source "${__DIR}/helpers.sh" ||  \
 echo "Functions not found"

setPipeline "${CONCOURSE_TARGET}" "${PRODUCT}" "${ENVIRONMENT}"
