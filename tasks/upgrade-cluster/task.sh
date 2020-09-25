#!/bin/bash

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

function login_pks_k8s_cluster() {
	local cluster="${1}"
	local password="${2}"

	printf "Logging into k8s cluster (%s)...\n" "${cluster}"
	echo "${password}" | pks get-credentials "${cluster}" > /dev/null 2>&1

	return $?
}

function main() {
    local cluster="${1}"
    local password="${2}"

    if ! login_pks_k8s_cluster "${cluster}" "${password}"; then
        echo
        printf "Failed to login to cluster '%s'\n" "${cluster}"
        exit 1
    fi

    pks upgrade-cluster "${cluster}" --non-interactive > upgrade.log 2>&1 &

    cluster_uuid=$(pks cluster "${cluster}" --json | jq -r .uuid)

    task_id=""
    {
        while [[ $(bosh -d "service-instance_${cluster_uuid}" tasks --column=state | head -3 | awk '{print $1}') =~ processing ]]; do
            current_task_id="$(bosh -d "service-instance_${cluster_uuid}" tasks --column=id | head -3 | awk '{print $1}')"
            printf "\ncurrent task: '%s', last task: '%s'\n" "$current_task_id" "$task_id"
            if [[ "$current_task_id" != "$task_id" ]]; then
                printf "Logging output from task '%s'\n" "$current_task_id"
                bosh task "$current_task_id" >> task.log 2>&1
            fi
            task_id="$current_task_id"
        done
    } &
    process_id=$!
    sleep 10
    tail -f task.log &
    tailpid=$!
    wait $process_id
    kill $tailpid
}

cluster="${1:-$CLUSTER}"
password="${2:-$PKS_PASSWORD}"

if [[ -z "${cluster}" ]]; then
    echo "PKS cluster is required"
    exit 1
fi

if [[ -z "${password}" ]]; then
    echo "PKS admin password is required"
    exit 1
fi

main "$cluster" "$password"
