#!/bin/sh

read -e -p "Enter the topic: " -i "use-case-1" topic
read -e -p "Enter the zk host/port: " -i "localhost:2181" zk_host_port
read -e -p "Enter the offset: " -i "--from-beginning" offset
read -e -p "Enter the consumer group id: " -i "consumer-group-1" consumer_group

echo "group.id=$consumer_group" > shared/$consumer_group.properties


read -e -p "Run new kafka consumer: " -i "y" new_consumer

if [[ "$new_consumer" == "n" || "$new_consumer" == "N" ]]; then

  docker exec -ti streamworks_kafka_broker bin/kafka-console-consumer.sh \
  --consumer.config /shared/$consumer_group.properties \
  --zookeeper $zk_host_port \
  --topic $topic \
  $offset

else

  read -e -p "Enter the bootstrap server: " -i "localhost:9092" bootstrap_server

  docker exec -ti streamworks_kafka_broker bin/kafka-console-consumer.sh \
  --new-consumer \
  --consumer.config /shared/$consumer_group.properties \
  --bootstrap-server $bootstrap_server \
  --zookeeper $zk_host_port \
  --topic $topic \
  $offset

fi