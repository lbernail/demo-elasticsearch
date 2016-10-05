#!/bin/bash

set -e
set -x

JAVA_HOME=/opt/java
ES_HOME=/usr/share/elasticsearch
export JAVA_HOME ES_HOME

# Install plugins
$ES_HOME/bin/plugin -install elasticsearch/elasticsearch-cloud-aws/2.6.0
$ES_HOME/bin/plugin -install lmenezes/elasticsearch-kopf
$ES_HOME/bin/plugin -install knapsack -url http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-knapsack/1.5.2.0/elasticsearch-knapsack-1.5.2.0-plugin.zip
$ES_HOME/bin/plugin -install elasticsearch/elasticsearch-river-twitter/2.6.0
