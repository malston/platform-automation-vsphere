#!/bin/bash

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
  printf "  %s --output=hw2/foundation/2.9 --folder=Foundation\n" "$0"
  printf "  %s --output=hw2/healthwatch/2.0 --folder=Healthwatch\n" "$0"
  printf "  %s --output=hw2/tas/2.9 --folder='Tanzu Application Service'\n" "$0"
  printf "  %s --all" "$0"
  printf "\n\n"
  echo "Flags:"
  printf "%s, --help\n" "-h"
  printf "%s, --output string\tThe directory where dashboards are saved (Relative to ./dashboards)\n" "-o"
  printf "%s, --folder string\tThe name of the Grafana folder where dashboards are stored\n" "-f"
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

function get_dashboard_dir() {
  local folder_file="${1}"
  echo $folder_file | rev | cut -d"/" -f2- | rev
}

function get_dashboards() {
  local folder_id="${1}"
  local folder_name="${2}"
  local dashboards_dir="${3}"

  printf "\n> Exporting '%s' dashboards\n" "$folder_name"
  for dash_uid in $(curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/search?folderIds=$folder_id&query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
    curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/dashboards/uid/$dash_uid" | jq -r > $dashboards_dir/${dash_uid}.json
    slug=$(cat $dashboards_dir/${dash_uid}.json | jq -r '.meta.slug')
    printf "\tto ${dashboards_dir/$BASE_DIR\//}/${slug}.json\n"
    mv $dashboards_dir/${dash_uid}.json $dashboards_dir/${slug}.json
  done
}

function create_folder_file() {
  local folder_name="${1}"
  local folder_file="${2}"

  folder=$(find_folder "${folder_name}")
  folder_uid=$(echo $folder  | jq -r '.[] | select(.type=="dash-folder") | .uid')
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/folders/$folder_uid"
}

function find_folder() {
  local folder_name=$(urlencode "${1}")
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/search?query=$folder_name"
}

function export_dashboards() {
  local folder_file="${1}"
  local folder_name="${2}"
  
  if [[ -f "$folder_file" ]]; then
    folder_id=$(cat "${folder_file}" | jq -r '.id')
    if [[ "$folder_id" = 'null' ]]; then
      folder_id=""
    fi
    if [[ -z "$folder_name" ]]; then
      folder_name=$(cat "${folder_file}" | jq -r '.title')
    fi
  fi

  if [[ -n "$folder_id" ]]; then
    get_dashboards "$folder_id" "$folder_name" $(get_dashboard_dir "$folder_file")
    return 0
  fi

  if [[ -n "$folder_name" ]]; then
    folder=$(create_folder_file "$folder_name" "$folder_file")
    echo $folder | jq -r > "$folder_file"
    folder_id=$(cat "${folder_file}" | jq -r '.id')
    get_dashboards "$folder_id" "$folder_name" $(get_dashboard_dir "$folder_file")
    return 0
  fi
  
  return 1
}

while [ "$1" != "" ]; do
    param=$(echo "$1" | awk -F= '{print $1}')
    value=$(echo "$1" | awk -F= '{print $2}')
    case $param in
        -h | --help)
            usage
            exit
            ;;
        -o | --output)
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

mkdir -p $DASHBOARDS_DIR

printf "\nExporting Grafana dashboards from %s\n" "$GRAFANA_URL"

if [[ -n $ALL ]]; then
  for f in $(find "$BASE_DIR/../dashboards" -name 'folder.json'); do
    export_dashboards "${f}" "${FOLDER_NAME}"
  done
  exit
fi

export_dashboards "${FOLDER_FILE}" "${FOLDER_NAME}"

if [[ $? != 0 ]]; then
  usage
  echo -e "\nDid not export any dashboards. Make sure folder '$FOLDER_FILE' exists"
  exit
fi
