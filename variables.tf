variable "CONFIG_FILE" {
  type        = string
  description = "Path to the YAML configuration file"
}

variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

######################################################

variable "kafka_cluster_api_key_dev" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_secret_dev" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_key_debug" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_secret_debug" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_key_ope" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_secret_ope" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_key_sta" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_secret_sta" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_key_int" {
  type    = string
  default = ""
}

variable "kafka_cluster_api_secret_int" {
  type    = string
  default = ""
}

##########################################################

variable "kafka_schema_registry_api_key_dev" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_secret_dev" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_key_debug" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_secret_debug" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_key_sta" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_secret_sta" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_key_ope" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_secret_ope" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_key_int" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
  default     = ""
}

variable "kafka_schema_registry_api_secret_int" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
  default     = ""
}