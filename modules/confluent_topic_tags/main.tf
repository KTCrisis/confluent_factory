# Récupération de l'environnement pour Confluent
data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.cluster_name
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_schema_registry_cluster" "schema_registry_cluster" {
  environment {
    id = data.confluent_environment.environment.id
  }
}

############################  topic-tags  ##############################################

locals {
  topic_tag_list = flatten([
    for topic in var.topics : [
      for tag_key, tag_value in var.tags : {
        tag_name   = tag_key # Use the key instead
        topic_name = topic.name
      }
    ]
  ])

  topic_tag_map = {
    for info in local.topic_tag_list :
    "${info.topic_name}-${info.tag_name}" => info
  }
}

# BIND TAGS
resource "confluent_tag_binding" "topic_tags" {
  for_each = local.topic_tag_map

  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }

  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.kafka_schema_registry_api_key
    secret = var.kafka_schema_registry_api_secret
  }

  tag_name    = var.tags[each.value.tag_name]
  entity_name = "${data.confluent_schema_registry_cluster.schema_registry_cluster.id}:${data.confluent_kafka_cluster.cluster.id}:${each.value.topic_name}"
  entity_type = "kafka_topic"

  lifecycle {
    ignore_changes = all
  }
}
