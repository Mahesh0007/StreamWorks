/*
 */
package com.cleverfishsoftware.streaming.couchbase.kafkaloader;

import com.couchbase.client.java.Bucket;
import com.couchbase.client.java.Cluster;
import com.couchbase.client.java.CouchbaseCluster;
import com.couchbase.client.java.document.JsonDocument;
import com.couchbase.client.java.document.json.JsonObject;
import kafka.consumer.Consumer;
import kafka.consumer.ConsumerConfig;
import kafka.consumer.KafkaStream;
import kafka.javaapi.consumer.ConsumerConnector;
import kafka.message.MessageAndMetadata;

import java.util.*;

/**
 *
 * @author peter
 */
public class KafkaCouchbaseLoader {

    public static void main(String[] args) throws Exception {

        final String defaultKafkaConsumerGroup = "splash_json_couchbase_loader";
        final String defaultKafkaZk = "localhost:2181";
        final String defaultKafkaZkTimeout = "10000";
        final String defaultKafkaTopic = "splash_json";
        final String defaultCouchbaseHost = "localhost";
        final String defaultCouchbaseBucket = "splash";


        Properties config = new Properties();
        config.put("zookeeper.connect", defaultKafkaZk);
        config.put("zookeeper.connectiontimeout.ms", defaultKafkaZkTimeout);
        config.put("group.id", defaultKafkaConsumerGroup);

        config.put("enable.auto.commit", "true");
        config.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        config.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        config.put("session.timeout.ms", "10000");
        config.put("fetch.min.bytes", "50000");
        config.put("receive.buffer.bytes", "262144");
        config.put("max.partition.fetch.bytes", "2097152");


        // this is required because of in order for burrow to get the offsets
        // toddpalino commented on Jun 18, 2015
        // Burrow should work out of the box once your clusters are configured, which they appear to be.
        // Are your consumers committing offsets to Kafka, or Zookeeper? This means that the offsets.storage
        // configuration parameter on your consumers must be set to "kafka". Currently, Burrow only supports
        // consumers that are committing offsets to Kafka. I'm looking into ways to efficiently support
        // Zookeeper offsets, but I haven't started any work on it yet.
        // https://github.com/linkedin/Burrow/issues/7 
        config.put("dual.commit.enabled", "false");
        config.put("offsets.storage", "kafka");



        ConsumerConfig consumerConfig = new kafka.consumer.ConsumerConfig(config);

        ConsumerConnector consumerConnector = Consumer.createJavaConsumerConnector(consumerConfig);

        Map<String, Integer> topicCountMap = new HashMap<>();
        topicCountMap.put(defaultKafkaTopic, 1);

        Map<String, List<KafkaStream<byte[], byte[]>>> consumerMap = consumerConnector.createMessageStreams(topicCountMap);

        List<KafkaStream<byte[], byte[]>> streams = consumerMap.get(defaultKafkaTopic);

        List<String> nodes = new ArrayList<>();
        nodes.add(defaultCouchbaseHost);

        Cluster cluster = CouchbaseCluster.create(nodes);
        final Bucket bucket = cluster.openBucket(defaultCouchbaseBucket);

        try {
            for (final KafkaStream<byte[], byte[]> stream : streams) {
                for (MessageAndMetadata<byte[], byte[]> msgAndMetaData : stream) {
                    String msg = convertPayloadToString(msgAndMetaData.message());
                    System.out.println(msgAndMetaData.topic() + ": " + msg);

                    try {
                        JsonObject doc = JsonObject.fromJson(msg);
                        String id = UUID.randomUUID().toString();
                        bucket.upsert(JsonDocument.create(id, doc));
                    } catch (Exception ex) {
                        System.out.println("Not a json object: " + ex.getMessage());
                    }
                }
            }
        } catch (Exception ex) {
            System.out.println("EXCEPTION!!!!" + ex.getMessage());
            cluster.disconnect();
        }

        cluster.disconnect();
    }

    private static String convertPayloadToString(final byte[] message) {
        String string = new String(message);
        return string;
    }
}
