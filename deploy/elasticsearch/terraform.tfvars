vpc_id            = "vpc-6a44b50f"
azs               = "eu-west-1a,eu-west-1b,eu-west-1c"
public_subnets    = "subnet-6f607c29,subnet-2c24da5b,subnet-c2ea39a7"
key_pair          = "aws-dev"

trusted_networks        = "0.0.0.0/0"

es_cluster              = "demo"
es_shards               = "5"
es_replicas             = "1"
es_min_masters          = "2"

es_data_instance_type   = "t2.medium"
es_data_disk_size       = "30"
es_data_nodes           = "3"
es_data_heap            = "2g"

es_client_instance_type = "t2.micro"
es_client_nodes         = "3"
es_client_heap          = "768m"

es_master_instance_type = "t2.micro"
es_master_nodes         = "3"
es_master_heap          = "768m"

