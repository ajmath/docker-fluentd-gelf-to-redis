# Docker Gelf log driver -> Redis with custom docker metadata and ec2 metadata

Simple fluentd container to pull logs from the gelf docker logging driver, write
docker metadata to a custom format, append ec2 metadata, and ship to redis for
further processing with logstash.

## environment variables
* `PULL_EC2_METADATA` - EC2 metadata is optional and will only be present when
  is set to something
* `LABELS` - Comma-separated list of docker labels to include in the event
* `REDIS_HOST` - Host name for the redis server in the form `my-redis-host.coolsite.com`
* `REDIS_PORT` - Optional.  Defaults to 6379
* `REDIS_KEY` - Redis key to RPUSH events into
* `LOGSTASH_OPTS` - Default set of options to apply to all events being sent through
  fluentd.  This should be an escaped json string.  This will be added to the `options` key of the event.   Per-container
  logstash opts can be set by setting the `LOGSTASH_OPTS` environment variable
  on the container whose logs are being ingested and passing `--log-opt env=LOGSTASH_OPTS`
  to you docker run command.


To run a docker container with this log driver:
```
docker run
  --log-driver=gelf
  --log-opt gelf-address=udp://x.x.x.x:5170
  --log-opt gelf-compression-type=none debian:jessie echo "Hello Gelf"
```

Example of the log event this will send to redis:
```
{
   "ec2" : {
      "instance-id" : "i-12345678",
      "public-ip" : "54.54.54.54",
      "private-ip" : "10.1.1.1",
      "instance-type" : "m3.large",
      "ami-id" : "ami-123456"
   },
   "instance-id" : "i-12345678",
   "message" : "Hello Gelf again",
   "host" : "96bd3871c82a",
   "@timestamp" : "2016-06-08T21:53:06.916687081+00:00",
   "@version" : "1",
   "docker" : {
      "labels" : {
        "foo" : "bar"
      },
      "image_tag" : "jessie",
      "docker_host" : "moby",
      "image_id" : "sha256:bb5d89f9b6cb74ecdbaea2b81dd51bfd34dbafb97952459c3f58154bc58b4131",
      "args" : "echo Hello Gelf again",
      "cid" : "1a96f285f76d30361f4ea01f7bc07e71e7db565eedb96e2aa2b5004c999a1f3d",
      "image" : "debian:jessie",
      "created" : "2016-06-08T21:53:06.587571259Z",
      "name" : "goofy_jones"
   }
}
```
