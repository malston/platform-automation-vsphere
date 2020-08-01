#!/bin/bash -e

if [ -z "${PKS_DOMAIN_NAME}" ]; then
  echo "Enter domain: (e.g., pez.vmware.com)"
  read -r PKS_DOMAIN_NAME
fi

if [ -z "${PKS_SUBDOMAIN_NAME}" ]; then
  echo "Enter subdomain: (e.g., haas-439)"
  read -r PKS_SUBDOMAIN_NAME
fi

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
  source "${__DIR}/set-om-creds.sh" ||  \
  echo "set-om-creds.sh not found"

ADMIN_PASSWORD=$(om credentials \
    -p pivotal-container-service \
    -c '.properties.uaa_admin_password' \
    -f secret)

printf "\n\nAdmin password: %s\n\n" "${ADMIN_PASSWORD}"

om credentials \
  -p pivotal-container-service \
  --credential-reference .pivotal-container-service.pks_tls \
  --credential-field cert_pem > /tmp/pks-ca.crt

pks login -a \
    "https://api.pks.${PKS_SUBDOMAIN_NAME}.${PKS_DOMAIN_NAME}" \
    -u admin \
    -p "${ADMIN_PASSWORD}" \
    --ca-cert /tmp/pks-ca.crt
