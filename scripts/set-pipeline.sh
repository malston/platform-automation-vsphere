#!/bin/bash

set -eo pipefail

CONCOURSE_TARGET="${1:-main}"
PRODUCT="${2:-deploy-pks}"
ENVIRONMENT="${3:-haas-439}"

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
[[ -f "${__DIR}/helpers.sh" ]] &&  \
 source "${__DIR}/helpers.sh" ||  \
 echo "Functions not found"

setPipeline "${CONCOURSE_TARGET}" "${PRODUCT}" "${ENVIRONMENT}"
