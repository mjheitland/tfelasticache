enabled = true

region = "eu-west-1"

availability_zones = ["eu-west-1a", "eu-west-1b"]

namespace = "tfelasticache"

stage = "dev"

name = "redis-test"

instance_type = "cache.t3.micro"

cluster_size = 1

family = "redis6.x"

engine_version = "6.x"

at_rest_encryption_enabled = false

transit_encryption_enabled = true

zone_id = "Z1XH7DTHLZRO5R"

cloudwatch_metric_alarms_enabled = true
