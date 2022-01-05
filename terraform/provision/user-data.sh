#!/bin/env bash
# Based on https://github.com/buildpacks/ci/blob/main/gh-runners/rhel-openshift/provision-scripts/user-data.sh
exec &> >(tee -a "/tmp/user-data.sh.log")
set -ex

echo "> Creating non-root user..."
adduser --ingroup sudo --disabled-password --gecos "" provisioner
# allow for PATH to persist
sed -i '/Defaults \+secure_path/s/^/#/' /etc/sudoers
# do not require password
sed -i '0,/%sudo/s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Add docker
apt-get update
apt-get install -y docker.io
usermod -aG docker provisioner
