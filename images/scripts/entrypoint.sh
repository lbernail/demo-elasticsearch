#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- /usr/share/elasticsearch/bin/elasticsearch "$@"
fi

if [ "$1" = '/usr/share/elasticsearch/bin/elasticsearch' ]; then
    if grep '##CLUSTER##' /etc/elasticsearch/elasticsearch.yml > /dev/null 2>&1 ; then
    # First run of the container, initialize configuration

        [ -n "$ES_CLUSTER" ] || ES_CLUSTER="es_cluster"
        [ -n "$ES_NODE_NAME" ] || ES_NODE_NAME="es_node"
        [ -n "$ES_ZONE" ] || ES_ZONE="es_zone"
        [ -n "$ES_SHARDS" ] || ES_SHARDS=5
        [ -n "$ES_REPLICAS" ] || ES_REPLICAS=1
        [ -n "$ES_DATA" ] || ES_DATA="true"
        [ -n "$ES_MASTER" ] || ES_MASTER="true"
        [ -n "$ES_MIN_MASTERS" ] || ES_MIN_MASTER=1
        [ -n "$ES_HTTP" ] || ES_HTTP="true"

        [ -n "$ES_HEAP_SIZE" ] || ES_HEAP_SIZE="2g"

        echo "Configuring elaticsearch"
        sed -i "s/##CLUSTER##/$ES_CLUSTER/
                s/##NODE_NAME##/$ES_NODE_NAME/
                s/##ZONE##/$ES_ZONE/
                s/##SHARDS##/$ES_SHARDS/
                s/##REPLICAS##/$ES_REPLICAS/
                s/##DATA##/$ES_DATA/
                s/##MASTER##/$ES_MASTER/
                s/##MIN_MASTERS##/$ES_MIN_MASTERS/
                s/##HTTP##/$ES_HTTP/
               " /etc/elasticsearch/elasticsearch.yml

        sed -i "s/##ES_HEAP_SIZE##/$ES_HEAP_SIZE/
               " /etc/default/elasticsearch
    fi 
fi

exec "$@"
