
data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

data "confluent_schema_registry_cluster" "schema_registry" {
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]
}

resource "confluent_schema" "schema" {

  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry.id
  }


  dynamic "schema_reference" {
    for_each = try(length(var.schema_references), 0) > 0 ? var.schema_references : []
    content {
      name         = schema_reference.value.name
      subject_name = schema_reference.value.subject_name
      version      = schema_reference.value.version
    }
  }

  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint
  subject_name  = var.subject_name
  format        = var.subject_format
  schema        = file(var.schema_path)
  # recreate_on_update = true
  hard_delete = true

  credentials {
    key    = var.kafka_schema_registry_api_key
    secret = var.kafka_schema_registry_api_secret
  }

}

resource "confluent_schema_registry_cluster_config" "schema_registry_config" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry.id
  }

  rest_endpoint       = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint
  compatibility_level = "NONE"
  credentials {
    key    = var.kafka_schema_registry_api_key
    secret = var.kafka_schema_registry_api_secret
  }
  depends_on = [data.confluent_schema_registry_cluster.schema_registry]
}