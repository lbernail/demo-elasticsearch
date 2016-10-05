#!/bin/bash

set -e
set -x

chown elasticsearch:elasticsearch /tmp/config/*
cp /tmp/config/elasticsearch /etc/default/elasticsearch
cp /tmp/config/*.yml /etc/elasticsearch
