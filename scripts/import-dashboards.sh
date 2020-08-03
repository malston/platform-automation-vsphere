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
  printf "  %s --path=gap --folder='GAP Dashboards'\n" "$0"
  printf "  %s --path=gap\n" "$0"
  printf "  %s --all" "$0"
  printf "\n\n"
  echo "Flags:"
  echo "Flags:"
  printf "%s, --help\n" "-h"
  printf "%s, --path string\tThe path to the folder under dashboards\n" "-p"
  printf "%s, --folder string\tThe name of the Grafana folder\n" "-f"
}

function get_dashboard_dir() {
  local folder_file="${1}"
  echo $folder_file | rev | cut -d"/" -f2- | rev
}

function create_folder() {
  local folder_name="${1}"

  curl -X POST -s -k -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "{\"title\": \"$folder_name\"}" $GRAFANA_URL/api/folders
}

function create_dashboard() {
  local dashboard="${1}"
  local folder_id="${2}"

  export FOLDER_ID=$folder_id

  envsubst < "$DASHBOARDS_DIR/$dashboard" > "/tmp/$dashboard"

  curl -X POST -s -k -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "$(cat /tmp/$dashboard)" $GRAFANA_URL/api/dashboards/db
}

function import_dashboards() {
    local folder_file="${1}"
    local dashboards_dir="${2}"

    folder_id=$(cat "${folder_file}" | jq -r '.id')
    if [[ "$folder_id" = 'null' ]]; then
      folder_name=$(cat "${folder_file}" | jq -r '.title')
      folder_id=$(create_folder "${folder_name}" | jq -r '.id')
    fi
    for file in $(ls $dashboards_dir); do
      create_dashboard "$file" "$folder_id"
    done
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

DASHBOARDS_DIR="$BASE_DIR/../dashboards/$DB_PATH"
FOLDER_FILE="$BASE_DIR/../dashboards/$DB_PATH/folder.json"

if [[ -n $ALL ]]; then
  for f in $(find "$DASHBOARDS_DIR" -name 'folder.json'); do
    import_dashboards "$f" $(get_dashboard_dir "$f")
  done
  exit
fi

if [[ -z $DB_PATH ]]; then
  usage
  exit
fi

import_dashboards "${FOLDER_FILE}" $(get_dashboard_dir "$FOLDER_FILE")

