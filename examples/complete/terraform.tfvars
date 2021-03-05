#--- General

region = "eu-west-1"

project = "tfelasticache"


#--- Redis ElastiCluster

enabled = true

availability_zones = ["eu-west-1a", "eu-west-1b"]

zone_id = "Z1XH7DTHLZRO5R"

namespace = "tfelasticache"

stage = "dev"

name = "redis-test"

instance_type = "cache.t3.micro"

cluster_size = 1

family = "redis6.x"

engine_version = "6.x"

at_rest_encryption_enabled = false

transit_encryption_enabled = false

cloudwatch_metric_alarms_enabled = true


#--- Test Jump Box

jumpbox_instance_type = "t2.micro"

key_name              = "tfelasticache"

public_key_path       = "~/.ssh/id_rsa.pub"
