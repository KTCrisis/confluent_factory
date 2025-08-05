data "confluent_environment" "environment" {
  display_name = var.kafka_cluster_environment
}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.kafka_cluster_name
  environment {
    id = data.confluent_environment.environment.id
  }
}

resource "confluent_kafka_topic" "topic" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
  topic_name    = var.kafka_topic_name
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
  partitions_count = var.kafka_topic_partitions
  config = {
    "retention.ms"   = var.kafka_topic_retention_ms
    "cleanup.policy" = var.kafka_topic_cleanup_policy
  }
}

