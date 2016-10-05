#!/bin/bash

set -e
set -x

BUILDDEPS=curl
apt-get update -q
export DEBIAN_FRONTEND=noninteractive
apt-get install -y $BUILDDEPS


# Install Cloudutils (we need a version from sid, 0.26 in jessie does not work for root partition)
apt-get install -y cloud-utils
curl -sSLo cloud-utils.deb http://ftp.fr.debian.org/debian/pool/main/c/cloud-utils/cloud-utils_0.27-2_all.deb
dpkg -i --force-depends cloud-utils.deb
rm cloud-utils.deb

install -o root -g root /tmp/cloud.cfg /etc/cloud/cloud.cfg

## Clear unneeded binaries
apt-get remove -y $BUILDDEPS
apt-get autoclean
apt-get --purge -y autoremove
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
