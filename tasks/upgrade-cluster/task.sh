#!/bin/bash

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

function login_pks_k8s_cluster() {
    local cluster="${1}"
    local username="${2}"
    local password="${3}"

    printf "Logging into k8s cluster (%s) with user (%s)...\n" "${cluster}" "${username}"
    echo "${password}" | pks get-credentials "${cluster}" > /dev/null 2>&1

    return $?
}

function main() {
    local cluster="${1}"
    local username="${2}"
    local password="${3}"

    if ! login_pks_k8s_cluster "${cluster}" "${username}" "${password}"; then
        echo
        printf "Failed to login to cluster '%s'\n" "${cluster}"
        exit 1
    fi

    pks upgrade-cluster "${cluster}" --non-interactive > upgrade.log 2>&1 &
    pks_process_id=$!

    cluster_uuid=$(pks cluster "${cluster}" --json | jq -r .uuid)

    while [[ $(bosh -d "service-instance_${cluster_uuid}" tasks --column=id | head -3 | awk '{print $1}') == '' ]]; do
        sleep 3
    done
    first_task_id=$(bosh -d "service-instance_${cluster_uuid}" tasks --column=id | head -3 | awk '{print $1}' || true)
    if [[ $first_task_id == '' ]]; then
	    echo "Could not find task for service-instance_${cluster_uuid}"
	    exit 1
    fi
    {
        last_task_id=""
        task_id=$first_task_id
        while [[ $task_id != '' ]]; do
            # printf "\nlast task: '%s', current task: '%s'\n" "$last_task_id" "$task_id"
            if [[ "$last_task_id" != "$task_id" ]]; then
                # printf "Logging output from task '%s'\n" "$task_id"
                bosh task "$task_id" >> task.log 2>&1
                last_task_id=$task_id
            fi
            sleep 15
            task_id=$(bosh -d "service-instance_${cluster_uuid}" tasks --column=id | head -3 | awk '{print $1}' || true)
        done
    } &
    process_id=$!
    while [ ! -f task.log ]; do
        sleep 1
    done
    tail -f task.log &
    tailpid=$!
    wait $process_id
    kill $tailpid
    wait $pks_process_id
    printf "\nFinished upgrading cluster '%s'\n" "${cluster}"
    last_task_id="$(bosh tasks --recent | head -1 | awk '{print $1}' || true)"
    # printf "\nlast task: '%s', first task: '%s'\n" "$last_task_id" "$first_task_id"
    for (( i=first_task_id; i<=last_task_id; i++ )); do
        bosh task "$i" >> tasks.log 2>&1
    done
    printf "\n\n-------------------------- COMPLETE LOG OUTPUT ----------------------------------\n"
    cat upgrade.log
    cat tasks.log
}

mkdir -p ~/.pks
cp pks-config/creds.yml ~/.pks/creds.yml

cluster="${1:-$CLUSTER}"
username="${2:-$PKS_USER}"
password="${3:-$PKS_PASSWORD}"

if [[ -z "${cluster}" ]]; then
    echo "PKS cluster is required"
    exit 1
fi

if [[ -z "${username}" ]]; then
    echo "PKS username is required"
    exit 1
fi

if [[ -z "${password}" ]]; then
    echo "PKS admin password is required"
    exit 1
fi

main "$cluster" "$username" "$password"
