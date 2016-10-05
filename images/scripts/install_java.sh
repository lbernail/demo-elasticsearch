#!/bin/bash

set -e
set -x

BUILDDEPS=curl
apt-get update -q
export DEBIAN_FRONTEND=noninteractive
apt-get install -y curl

# Install java
JAVA_SHORT=${JAVA_VERSION%-*}
curl -sSLo /tmp/java.tar.gz http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}/server-jre-${JAVA_SHORT}-linux-x64.tar.gz \
    -H 'Cookie: oraclelicense=accept-securebackup-cookie'
mkdir -p /opt/java
tar -zx -C /opt/java -f /tmp/java.tar.gz --strip-components 1

## Clear unneeded binaries
apt-get remove -y $BUILDDEPS
apt-get autoclean
apt-get --purge -y autoremove
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
