#!/bin/bash

# https://kvz.io/bash-best-practices.html
# Use set -o errexit (a.k.a. set -e) to make your script exit when a command fails.
# Use set -o pipefail so that the exit status of the last command that threw a non-zero exit code is returned.
# Use set -o nounset (a.k.a. set -u) to exit when your script tries to use undeclared variables.

set -o errexit
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$GRAFANA_URL" ]]; then
  echo -n "Enter the grafana url: ";
  read -rs GRAFANA_URL
fi

if [[ -z "$KEY" ]]; then
  echo "No API key found. Get one from $GRAFANA_URL/org/apikeys and run 'KEY=<API key> $0'";
  read -rs KEY
fi

function usage() {
  echo "Usage:"
  echo "  $0 [flags]"
  echo ""
  echo "Examples:"
  printf "  %s --path=hw2/foundation/2.9 --folder=Foundation\n" "$0"
  printf "  %s --path=hw2/healthwatch/2.0 --folder=Healthwatch\n" "$0"
  printf "  %s --path=hw2/tas/2.9 --folder='Tanzu Application Service'" "$0"
  printf "\n\n"
  echo "Flags:"
  echo "Flags:"
  printf "%s, --help\n" "-h"
  printf "%s, --path string\tThe path to the folder under dashboards\n" "-p"
  printf "%s, --folder string\tThe name of the Grafana folder\n" "-f"
}

function get_dashboard_dir() {
  local folder_file="${1}"
  echo $FOLDER_FILE | rev | cut -d"/" -f2- | rev 
}

function process_dashboards() {
  local folder_file="${1}"

  if [[ -f "$folder_file" ]]; then
    export FOLDER_ID=$(cat "${folder_file}" | jq -r '.id')
    if [[ "$FOLDER_ID" = 'null' ]]; then
      export FOLDER_ID=""
    fi
    if [[ -z "$FOLDER_NAME" ]]; then
      export FOLDER_NAME=$(cat "${folder_file}" | jq -r '.title')
    fi
  fi

  if [[ -n "$FOLDER_ID" ]]; then
    get_dashboards "$FOLDER_ID" $(get_dashboard_dir "$folder_file")
    return 0
  fi

  if [[ -n "$FOLDER_NAME" ]]; then
    create_folder "$FOLDER_NAME"
    FOLDER_ID=$(cat "${folder_file}" | jq -r '.id')
    get_dashboards "$FOLDER_ID" $(get_dashboard_dir "$folder_file")
    return 0
  fi
  return 1
}

function urlencode() {
  local l=${#1}
  for (( i = 0 ; i < l ; i++ )); do
    local c=${1:i:1}
    case "$c" in
      [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
      ' ') printf + ;;
      *) printf '%%%.2X' "'$c"
    esac
  done
}

function get_dashboards() {
  local folder_id="${1}"
  local dashboards_dir="${2}"
  echo "Exporting Grafana dashboards from $GRAFANA_URL"
  for dash_uid in $(curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/search?folderIds=$folder_id&query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
    curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/dashboards/uid/$dash_uid" | jq -r > $dashboards_dir/${dash_uid}.json
    slug=$(cat $dashboards_dir/${dash_uid}.json | jq -r '.meta.slug')
    mv $dashboards_dir/${dash_uid}.json $dashboards_dir/${slug}.json
  done
}

function create_folder() {
  local folder_name="${1}"
  folder_uid=$(find_folder "${folder_name}")
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/folders/$folder_uid" | jq -r > "$FOLDER_FILE"
}

function find_folder() {
  local folder_name=$(urlencode "${1}")
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/search?query=$folder_name" | jq -r '.[].uid'
}

while [ "$1" != "" ]; do
    param=$(echo "$1" | awk -F= '{print $1}')
    value=$(echo "$1" | awk -F= '{print $2}')
    case $param in
        -h | --help)
            usage
            exit
            ;;
        -p | --path)
            DB_PATH=$value
            ;;
        -f | --folder)
            FOLDER_NAME=$value
            ;;
        --all)
            ALL=true
            ;;
        *)
            echo ""
            echo "Invalid option: [$param]"
            echo ""
            usage
            exit 1
            ;;
    esac
    shift
done

DASHBOARDS_DIR=$BASE_DIR/../dashboards/$DB_PATH
FOLDER_FILE=$BASE_DIR/../dashboards/$DB_PATH/folder.json

mkdir -p $DASHBOARDS_DIR

if [[ -n $ALL ]]; then
  for f in $(find ./dashboards -name 'folder.json'); do 
    echo $f
    FOLDER_FILE="$f"
    process_dashboards "${FOLDER_FILE}"
  done
  exit
fi

process_dashboards "${FOLDER_FILE}"

if [[ $? > 0 ]]; then
  usage
  exit
fi
