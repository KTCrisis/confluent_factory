
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

# variable "kafka_cluster_api_key" {
#   type = string
# }

# variable "kafka_cluster_api_secret" {
#   type = string
# }

# variable "kafka_schema_registry_api_key" {
#   type        = string
#   description = "Schema Registry API Key for data.confluent_schema_registry"
# }

# variable "kafka_schema_registry_api_secret" {
#   type        = string
#   description = "Schema Registry API Secret for data.confluent_schema_registry"
# }






