variable "vpc_id" {}
variable "azs" {}
variable "public_subnets" {}

variable "trusted_networks" {}

variable "es_cluster" {}
variable "es_shards" {}
variable "es_replicas" {}
variable "es_ami" {}
variable "es_min_masters" {}

variable "es_data_instance_type" {}
variable "es_data_disk_size" {}
variable "es_data_nodes" {}
variable "es_data_heap" {}

variable "es_client_instance_type" {}
variable "es_client_nodes" {}
variable "es_client_heap" {}

variable "es_master_instance_type" {}
variable "es_master_nodes" {}
variable "es_master_heap" {}

variable "key_pair" {}
