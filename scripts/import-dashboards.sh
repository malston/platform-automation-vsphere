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
  printf "  %s --input=acme --folder='Acme Dashboards'\n" "$0"
  printf "  %s --input=acme\n" "$0"
  printf "  %s --all" "$0"
  printf "\n\n"
  echo "Flags:"
  printf "%s, --help\n" "-h"
  printf "%s, --input string\tThe directory where dashboards are located (Relative to ./dashboards)\n" "-i"
  printf "%s, --folder string\tThe name of the Grafana folder\n" "-f"
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

function folder_exists_by_id() {
  local folder_id="${1}"

  if [[ ! "$folder_id" = 'null' ]] && [[ -n "$folder_id" ]]; then
    folder=$(find_folder_by_id "${folder_id}")
    folder_id=$(echo $folder  | jq -r '.id | select(.type=="dash-folder")')
  elif [[ ! "$folder_id" = 'null' ]] && [[ -z "$folder_id" ]]; then
    return 0
  fi

  return 1
}

function find_folder_by_id() {
  local folder_id="${1}"
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/folders/id/${folder_id}"
}

function find_folder_by_name() {
  local folder_name=$(urlencode "${1}")
  curl -s -k -H "Authorization: Bearer $KEY" "$GRAFANA_URL/api/search?query=$folder_name"
}

function create_folder() {
  local folder_name="${1}"

  curl -X POST -s -k -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "{\"title\": \"$folder_name\"}" $GRAFANA_URL/api/folders
}

function create_dashboard() {
  local dashboard="${1}"
  local folder_id="${2}"
  local folder_name="${3}"
  local dashboards_dir="${4}"

  raw_payload=$(cat $dashboards_dir/$dashboard | jq --compact-output --argjson overwrite true '. + {overwrite: $overwrite}' \
                                                      | jq --compact-output --argjson folderId "${folder_id}" '. + {folderId: $folderId}')
  dashboard_value=$(echo "$raw_payload" | tr '\r\n' ' ' | jq -r '.dashboard' | jq --argjson id null '. + {id: $id}')
  dashboard_payload=$(echo "$raw_payload" | tr '\r\n' ' ' | jq --argjson dashboard "${dashboard_value}" '. + {dashboard: $dashboard}')

  printf "\n> Creating dashboard '%s' into '%s' folder\n" "$dashboard" "$folder_name"
  curl -X POST -s -k -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "$(echo "${dashboard_payload}")" $GRAFANA_URL/api/dashboards/db | jq .
}

function import_dashboards() {
  local folder_file="${1}"
  local dashboards_dir="${2}"
  local folder_name="${3}" # Optional

  if [[ -z ${folder_name} ]]; then
    folder_name=$(cat "${folder_file}" | jq -r '.title')
  fi
  
  folder_id=$(cat "${folder_file}" | jq -r '.id')
  if [[ ! $(folder_exists_by_id) ]]; then
    folder=$(create_folder "${folder_name}")
    folder_id=$(echo "${folder}" | jq -r '.id')
    if [[ "$folder_id" = 'null' ]]; then
      folder=$(find_folder_by_name "${folder_name}")
      folder_id=$(echo $folder  | jq -r '.[] | select(.type=="dash-folder") | .id')
    fi
  else
    folder=$(find_folder_by_id "${folder_id}")
    folder_id=$(echo $folder  | jq -r '.id | select(.type=="dash-folder")')
    if [[ "$folder_id" = 'null' ]]; then
      folder=$(create_folder "${folder_name}")
      folder_id=$(echo "${folder}" | jq -r '.id')
    fi
  fi
  for file in $(ls $dashboards_dir | grep -iv 'folder.json'); do
    create_dashboard "$file" "$folder_id" "$folder_name" "$dashboards_dir"
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
        -i | --input)
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

printf "\nImporting local Grafana dashboards to %s\n" "$GRAFANA_URL"

if [[ -n $ALL ]]; then
  for f in $(find "$DASHBOARDS_DIR" -name 'folder.json'); do
    dashboard_dir=$(get_dashboard_dir "$f")
    import_dashboards "$f" "$dashboard_dir"
  done
  exit
fi

if [[ -z $DB_PATH ]]; then
  usage
  exit
fi

if [[ ! -f "$FOLDER_FILE" ]]; then
  usage
  echo -e "\nFolder $FOLDER_FILE does not exist"
  exit
fi

import_dashboards "${FOLDER_FILE}" $(get_dashboard_dir "$FOLDER_FILE") "${FOLDER_NAME}"
