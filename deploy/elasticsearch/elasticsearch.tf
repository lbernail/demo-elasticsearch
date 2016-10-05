resource "aws_security_group" "elasticsearch" {
    name = "elasticsearch"
    description = "Internal elasticsearch communication"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = "9300"
        to_port = "9300"
        protocol = "tcp"
        self = "true"
    }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags { Name = "ES internal" }
}


resource "aws_security_group" "es_clients" {
    name = "es_client"
    description = "Client access to elasticsearch"
    vpc_id = "${var.vpc_id}"
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags { Name = "ES clients" }
}


resource "aws_security_group" "es_client_nodes" {
    name = "es_client_nodes"
    description = "Client access to elasticsearch"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = "9200"
        to_port = "9200"
        protocol = "tcp"
        cidr_blocks = ["${split(",",var.trusted_networks)}"]
    }
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["${split(",",var.trusted_networks)}"]
    }
    ingress {
        from_port = "9200"
        to_port = "9200"
        protocol = "tcp"
        security_groups = ["${aws_security_group.es_clients.id}"]
    }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags { Name = "ES client Nodes" }
}


resource "aws_iam_role" "es" {
    name = "es_role"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "es" {
    name = "es_role_policy"
    role = "${aws_iam_role.es.id}"
    policy = <<EOF
{
    "Statement": [
        {
            "Action": [ "ec2:DescribeInstances" ],
            "Effect": "Allow",
            "Resource": [ "*" ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_instance_profile" "es" {
    name = "es_profile"
    roles = ["${aws_iam_role.es.name}"]
}


## Elasticsearch master nodes
resource "template_file" "es_master_user_data" {
    filename = "es_user_data.tpl"
#    lifecycle { create_before_destroy = true }
    vars {
        es_cluster = "${var.es_cluster}"
        es_node_name = ""
        es_shards = "${var.es_shards}"
        es_replicas = "${var.es_replicas}"
        es_data = "false"
        es_master = "true"
        es_min_masters = "${var.es_master_nodes/2+1}"
        es_http = "false"
        es_sg = "${aws_security_group.elasticsearch.name}"
        es_heap_size = "${var.es_master_heap}"
    }
}

resource "aws_launch_configuration" "es_master" {
    image_id = "${var.es_ami}"
    instance_type = "${var.es_master_instance_type}"
    key_name = "${var.key_pair}"
    security_groups = ["${aws_security_group.elasticsearch.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.es.id}"
    user_data="${template_file.es_master_user_data.rendered}"
    associate_public_ip_address = true
#    lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "es_master" {
    name = "es_master"
    launch_configuration = "${aws_launch_configuration.es_master.id}"
    availability_zones = ["${split(",",var.azs)}"]
    vpc_zone_identifier = ["${split(",",var.public_subnets)}"]

    tag {
        key = "Name"
        value = "Elastic Master"
        propagate_at_launch = "true"
    }

    min_size = "${var.es_master_nodes}"
    max_size = "${var.es_master_nodes}"
    desired_capacity = "${var.es_master_nodes}"
}


## Elasticsearch data nodes
resource "template_file" "es_data_user_data" {
    filename = "es_user_data.tpl"
#    lifecycle { create_before_destroy = true }
    vars {
        es_cluster = "${var.es_cluster}"
        es_node_name = ""
        es_shards = "${var.es_shards}"
        es_replicas = "${var.es_replicas}"
        es_data = "true"
        es_master = "false"
        es_min_masters = "${var.es_master_nodes/2+1}"
        es_http = "false"
        es_sg = "${aws_security_group.elasticsearch.name}"
        es_heap_size = "${var.es_data_heap}"
    }
}

resource "aws_launch_configuration" "es_data" {
    image_id = "${var.es_ami}"
    instance_type = "${var.es_data_instance_type}"
    key_name = "${var.key_pair}"
    security_groups = ["${aws_security_group.elasticsearch.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.es.id}"
    root_block_device {
        volume_type = "gp2"
        volume_size = "${var.es_data_disk_size}"
    }
    user_data="${template_file.es_data_user_data.rendered}"
    associate_public_ip_address = true
#    lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "es_data" {
    name = "es_data"
    launch_configuration = "${aws_launch_configuration.es_data.id}"
    availability_zones = ["${split(",",var.azs)}"]
    vpc_zone_identifier = ["${split(",",var.public_subnets)}"]

    tag {
        key = "Name"
        value = "Elastic Data"
        propagate_at_launch = "true"
    }

    min_size = "${var.es_data_nodes}"
    max_size = "${var.es_data_nodes}"
    desired_capacity = "${var.es_data_nodes}"
}


## Elasticsearch client nodes
resource "template_file" "es_client_user_data" {
    filename = "es_user_data.tpl"
#    lifecycle { create_before_destroy = true }
    vars {
        es_cluster = "${var.es_cluster}"
        es_node_name = ""
        es_shards = "${var.es_shards}"
        es_replicas = "${var.es_replicas}"
        es_data = "false"
        es_master = "false"
        es_min_masters = "${var.es_master_nodes/2+1}"
        es_http = "true"
        es_sg = "${aws_security_group.elasticsearch.name}"
        es_heap_size = "${var.es_client_heap}"
    }
}

resource "aws_launch_configuration" "es_client" {
    image_id = "${var.es_ami}"
    instance_type = "${var.es_client_instance_type}"
    key_name = "${var.key_pair}"
    security_groups = ["${aws_security_group.elasticsearch.id}","${aws_security_group.es_client_nodes.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.es.id}"
    user_data="${template_file.es_client_user_data.rendered}"
    associate_public_ip_address = true
#    lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "es_client" {
    name = "es_client"
    launch_configuration = "${aws_launch_configuration.es_client.id}"
    availability_zones = ["${split(",",var.azs)}"]
    vpc_zone_identifier = ["${split(",",var.public_subnets)}"]

    tag {
        key = "Name"
        value = "Elastic Client"
        propagate_at_launch = "true"
    }

    min_size = "${var.es_client_nodes}"
    max_size = "${var.es_client_nodes}"
    desired_capacity = "${var.es_client_nodes}"
}


output "clients_sg" { value = "${aws_security_group.es_clients.id}" }
