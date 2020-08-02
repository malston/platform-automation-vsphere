#!/bin/bash 

# https://kvz.io/bash-best-practices.html
# Use set -o errexit (a.k.a. set -e) to make your script exit when a command fails.
# Use set -o pipefail so that the exit status of the last command that threw a non-zero exit code is returned.
# Use set -o nounset (a.k.a. set -u) to exit when your script tries to use undeclared variables.

set -o errexit
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DB_PATH="${1}"

if [[ -z "$GRAFANA_URL" ]]; then
  echo -n "Enter the grafana url: ";
  read -rs GRAFANA_URL
fi

if [[ -z "$KEY" ]]; then
  echo "No API key found. Get one from $GRAFANA_URL/org/apikeys and run 'KEY=<API key> $0'";
  read -rs KEY
fi

set -o nounset

DASHBOARDS_DIR=$BASE_DIR/../dashboards/$DB_PATH

for file in $(ls $DASHBOARDS_DIR); do
  curl -X POST -k -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "$(cat $DASHBOARDS_DIR/$file)" $GRAFANA_URL/api/dashboards/db
done
