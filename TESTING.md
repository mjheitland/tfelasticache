# Test ElastiCache from a Jump Box

Connect to Redis cluster and test that the cache is working (this test works only if the cluster has been set up with 'transit_encryption_enabled = false'). Use either Route53 CName or primary cluster endpoint:
```
ssh ~/.ssh/id_rsa ec2-user@<public ip address of jump box>
cd redis-stable
src/redis-cli -h tfelasticache-dev-redis-test.r53.heitland-it.de -p 6379
set h 'hi and hello'
get h
exit
```