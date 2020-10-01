#!/usr/bin/env bash

set -eux

mkdir -p logs

timestamp="$(date '+%Y%m%d.%-H%M.%S')"

/opt/tasks/show-logs > logs/"events-${JOB_NAME}-${timestamp}.log"