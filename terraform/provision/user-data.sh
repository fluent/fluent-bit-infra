#!/bin/env bash
# Based on https://github.com/buildpacks/ci/blob/main/gh-runners/rhel-openshift/provision-scripts/user-data.sh
set -ex

# echo "> Enable password login..."
# sed -i '/PasswordAuthentication \+no/s/no/yes/' /etc/ssh/sshd_config
# systemctl restart sshd.service

echo "> Creating non-root user..."
# NOTE: user should NOT have a password so that they may not login via SSH
useradd -G wheel user
# allow for PATH to persist
sed -i '/Defaults \+secure_path/s/^/#/' /etc/sudoers
# don't require password
sed -i '0,/%wheel/s/ALL$/NOPASSWD: ALL/' /etc/sudoers
