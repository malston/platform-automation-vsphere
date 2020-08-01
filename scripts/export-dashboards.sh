#!/bin/bash

# https://kvz.io/bash-best-practices.html
# Use set -o errexit (a.k.a. set -e) to make your script exit when a command fails.
# Use set -o pipefail so that the exit status of the last command that threw a non-zero exit code is returned.
# Use set -o nounset (a.k.a. set -u) to exit when your script tries to use undeclared variables.

set -o errexit
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DB_PATH="${1}"
FOLDER_ID=61

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

mkdir -p $DASHBOARDS_DIR

echo "Exporting Grafana dashboards from $GRAFANA_URL"
for dash_uid in $(curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/search?folderIds=$FOLDER_ID&query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/dashboards/uid/$dash_uid" | jq -r > $DASHBOARDS_DIR/${dash_uid}.json
  slug=$(cat $DASHBOARDS_DIR/${dash_uid}.json | jq -r '.meta.slug')
  mv $DASHBOARDS_DIR/${dash_uid}.json $DASHBOARDS_DIR/${slug}.json
done
