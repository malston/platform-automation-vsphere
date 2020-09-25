#!/usr/bin/env bash

function login_pks() {
	(
		echo "Logging into PKS (${PKS_API_URL})..."
		pks login -a "${PKS_API_URL}" -u "${PKS_USER}" -p "${PKS_PASSWORD}" -k
	)
}

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

login_pks || exit 1

cp ~/.pks/creds.yml pks-config/creds.yml