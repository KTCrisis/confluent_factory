output "Kafka_Cluster_scope" {
  value = {
    for key in confluent_api_key.Kafka_Cluster_api_key :
    "credentials" => {
      key    = key.id
      secret = nonsensitive(key.secret)
    }
  }
  # sensitive = false
}

output "Flink_Region_scope" {
  value = {
    for key in confluent_api_key.Flink_Region_api_key :
    "credentials" => {
      key    = key.id
      secret = nonsensitive(key.secret)
    }
  }
  # sensitive = false
}

output "ksqlDB_Cluster_scope" {
  value = {
    for key in confluent_api_key.ksqlDB_Cluster_api_key :
    "credentials" => {
      key    = key.id
      secret = nonsensitive(key.secret)
    }
  }
  # sensitive = false
}

output "Schema_Registry_scope" {
  value = {
    for key in confluent_api_key.Schema_Registry_api_key :
    "credentials" => {
      key    = key.id
      secret = nonsensitive(key.secret)
    }
  }
  # sensitive = false
}

output "Schema_registry_rest_endpoint" {
  value = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint
}

