variable "kafka_schema_registry_api_key" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
}
variable "cluster_name" {
  description = "The Confluent cluster name"
  type        = string
}
variable "kafka_schema_registry_api_secret" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  sensitive   = true
}
variable "confluent_kafka_environment" {
  description = "The Confluent environment name"
  type        = string
}
variable "tags" {
  description = "Map des tags à créer (clé = description, valeur = nom du tag)"
  type        = map(string)
}