#!/bin/bash

set -e
set -x

BUILDDEPS=curl
apt-get update -q
export DEBIAN_FRONTEND=noninteractive
apt-get install -y curl

# Configure ES repository
curl -sS https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/${ES_VERSION}/debian stable main" | tee -a /etc/apt/sources.list

# Install elasticsearch
apt-get update -q
apt-get install -y elasticsearch

## Clear unneeded binaries
apt-get remove -y $BUILDDEPS
apt-get autoclean
apt-get --purge -y autoremove
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
