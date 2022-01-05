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

# Add dependencies and allow for other users of apt-get
# https://blog.sinjakli.co.uk/2021/10/25/waiting-for-apt-locks-without-the-hacky-bash-scripts/
apt-get -o DPkg::Lock::Timeout=60 update
apt-get -o DPkg::Lock::Timeout=-1 install -y docker.io curl jq
usermod -aG docker provisioner
