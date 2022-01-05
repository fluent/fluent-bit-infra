#!/bin/env bash
# Based on https://github.com/buildpacks/ci/blob/main/gh-runners/rhel-openshift/provision-scripts/github-runner.destroy.sh
exec &> >(tee -a "/tmp/github-runner.destroy.sh.log")
set -ex

if [ "$EUID" -eq 0 ]; then
    echo "Must be ran as a non-root user"
    exit 1
fi

while getopts t:o:r: flag; do
    case "${flag}" in
        t) GH_TOKEN=${OPTARG};;
        o) GH_OWNER=${OPTARG};;
        r) GH_REPO=${OPTARG};;
        *) echo "Unsupported option";;
    esac
done

export RUNNER_ALLOW_RUNASROOT="1"

ACTIONS_RUNNER_INSTALL_DIR="${HOME}/runner-${GH_OWNER}-${GH_REPO}"
ACTIONS_RUNNER_WORK_DIR="${ACTIONS_RUNNER_INSTALL_DIR}-work"

pushd "$ACTIONS_RUNNER_INSTALL_DIR" > /dev/null
    echo "> Stopping service..."
    sudo ./svc.sh stop || true

    echo "> Uninstalling service..."
    sudo ./svc.sh uninstall || true

    echo "> Unregistering runner..."
    ACTIONS_RUNNER_INPUT_TOKEN=$(curl -sS -X POST -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/remove-token" --header "authorization: Bearer ${GH_TOKEN}" | jq -r .token)
    echo "Token: $ACTIONS_RUNNER_INPUT_TOKEN"

    ./config.sh remove --unattended --token "$ACTIONS_RUNNER_INPUT_TOKEN"

    echo "> Cleaning up..."
    rm -rf "$ACTIONS_RUNNER_INSTALL_DIR" "$ACTIONS_RUNNER_WORK_DIR"
popd > /dev/null
