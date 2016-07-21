#!/bin/sh

rm -f tmp/*

cmd=$1
img_name='streamworks/burrow'
container_name='streamworks_kafka_burrow'
bash_cmd='/bin/bash'
burrow_cmd='/go/bin/burrow -config /etc/burrow/burrow.cfg'
volumes="
  -v $PWD/Burrow/docker-config:/etc/burrow/
  -v $PWD/tmp:/var/tmp/burrow
"
docker run -d -ti \
  --net host \
  $volumes \
  --name $container_name \
  $img_name \
  $bash_cmd
