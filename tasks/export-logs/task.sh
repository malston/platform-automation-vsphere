#!/usr/bin/env bash

set -eux

mkdir -p logs

timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"

/opt/tasks/show-logs > logs/"${EXPORT_FILE_NAME}-${timestamp}"