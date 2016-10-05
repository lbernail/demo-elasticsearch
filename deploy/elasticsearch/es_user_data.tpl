#!/bin/bash

AZ=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(echo $AZ | sed s'/.$//')

sed -i.bak "s/##CLUSTER##/${es_cluster}/
            s/##NODE_NAME##/${es_node_name}/
            s/##ZONE##/$AZ/
            s/##SHARDS##/${es_shards}/
            s/##REPLICAS##/${es_replicas}/
            s/##DATA##/${es_data}/
            s/##MASTER##/${es_master}/
            s/##MIN_MASTERS##/${es_min_masters}/
            s/##HTTP##/${es_http}/
           " /etc/elasticsearch/elasticsearch.yml

cat <<EOF >> /etc/elasticsearch/elasticsearch.yml
discovery.type: "ec2"
discovery.ec2.groups: "${es_sg}"
cloud.aws.region: "$REGION"
discovery.zen.ping.multicast.enabled: false
EOF

sed -i.bak "s/##ES_HEAP_SIZE##/${es_heap_size}/
           " /etc/default/elasticsearch

systemctl enable elasticsearch.service
systemctl start elasticsearch.service
