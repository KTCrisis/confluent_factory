output "schema_registry_id" {
  description = "The ID of the Schema Registry cluster"
  value       = data.confluent_schema_registry_cluster.schema_registry.id
}

output "Schema_registry_rest_endpoint" {
  description = "The REST endpoint of the Schema Registry cluster"
  value       = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint
}
