#!/usr/bin/env bash

set -eux

mkdir -p logs

timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"
export timestamp

# '$timestamp' must be a literal, because envsubst uses it as a filter
# this allows us to avoid accidentally interpolating anything else.
# shellcheck disable=SC2016
output_file_name="$(echo "${EXPORT_FILE_NAME}" | sed -e s/'$timestamp'/$timestamp/g)"

/opt/tasks/show-logs > logs/"${output_file_name}"