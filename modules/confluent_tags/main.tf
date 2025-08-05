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

resource "confluent_tag" "tags" {
  for_each = var.tags

  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }

  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint

  credentials {
    key    = var.kafka_schema_registry_api_key
    secret = var.kafka_schema_registry_api_secret
  }

  name        = each.value
  description = each.key
}