# Variables
variable "kafka_schema_registry_api_key" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
}

variable "kafka_schema_registry_api_secret" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  sensitive   = true
}

variable "tags" {
  description = "Map of tags"
  type        = map(string)
}


variable "confluent_kafka_environment" {
  description = "The Confluent environment name"
  type        = string
}

variable "cluster_name" {
  description = "The Confluent cluster name"
  type        = string
}

variable "topics" {
  description = "The list of topics"
  type = list(object({
    name         = string
    partitions   = number
    retention_ms = number
  }))
}