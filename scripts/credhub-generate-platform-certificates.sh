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

if [[ -z "${PKS_SUBDOMAIN_NAME}" ]]; then
    echo "Enter the PKS subdomain (e.g. dev): "
    read -r PKS_SUBDOMAIN_NAME
fi

if [[ -z "${PKS_DOMAIN_NAME}" ]]; then
    echo "Enter the PKS root domain (e.g. pks.example.com): "
    read -r PKS_DOMAIN_NAME
fi

DOMAIN="${PKS_SUBDOMAIN_NAME}.${PKS_DOMAIN_NAME}"
KEY_BITS=2048
DAYS=365

PREFIX="platform-automation/${ENVIRONMENT_NAME}"

# NSX-T Manager TLS Certificate
credhub generate --type "certificate" \
    --name "${PREFIX}/nsx_mgr_tls" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "${NSX_VIP}" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --ca "platform-automation/certificate_authority" \
    --no-overwrite

# NSXT_CERT_NAME="nsxmgr-01"
# credhub set --type "certificate" \
#     --name "${PREFIX}/nsx_mgr_tls" \
#     -c ./control-plane/secrets/haas-440/nsx_ca.pem
# -r $(credhub get -n platform-automation/certificate_authority -k ca -q)

# NSX-T SuperUser Principal Identity TLS Certificate
credhub generate --type "certificate" \
    --name "${PREFIX}/nsx_superuser_tls" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "${NSX_MANAGER}" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --ca "platform-automation/certificate_authority" \
    --no-overwrite

# PKS TLS Certificate
credhub generate --type "certificate" \
    --name "${PREFIX}/pks_tls" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "api.${DOMAIN}" \
    --alternative-name "*.${DOMAIN}" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --ca "platform-automation/certificate_authority" \
    --no-overwrite

credhub get -n "${PREFIX}/pks_tls" -k certificate > /tmp/pks_tls_cert.pem
credhub get -n "${PREFIX}/pks_tls" -k private_key > /tmp/pks_tls_private_key.pem
kubectl create secret tls pks-tls-secret --key=/tmp/pks_tls_private_key.pem --cert=/tmp/pks_tls_cert.pem

# Harbor TLS Certificate
credhub generate --type "certificate" \
    --name "${PREFIX}/harbor_tls" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "harbor.${DOMAIN}" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --ca "platform-automation/certificate_authority" \
    --no-overwrite

# Reliability View Grafana Certificate
credhub generate --type "certificate" \
    --name "${PREFIX}/grafana_tls" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "grafana.${DOMAIN}" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --ca "platform-automation/certificate_authority" \
    --no-overwrite

# Reliability View Grafana-02 Certificate
credhub generate --type "certificate" \
    --name "${PREFIX}/grafana02_tls" \
    --key-length "${KEY_BITS}" \
    --duration "${DAYS}" \
    --common-name "grafana-02.${DOMAIN}" \
    --organization "Pivotal" \
    --organization-unit "Pivotal Labs Services" \
    --locality "San Francisco" \
    --state "CA" \
    --country "US" \
    --ca "platform-automation/certificate_authority" \
    --no-overwrite
