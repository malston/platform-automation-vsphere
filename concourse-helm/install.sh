#!/bin/bash

set -ox pipefail

namespace="${1:-default}"
values_file="${2:-./deployment-values.yml}"

helm upgrade -i concourse \
    --namespace "${namespace}" \
    --values "$values_file" \
    --set "persistence.worker.storageClass=pacific-gold-storage-policy" \
    --set "postgresql.persistence.storageClass=pacific-gold-storage-policy" \
    --debug \
    ./charts
