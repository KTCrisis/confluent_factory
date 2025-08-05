variable "service_account_name" {
  description = "The service account name"
  type        = string

}

variable "confluent_kafka_environment" {
  description = "the confluent environment name"
  type        = string

}

variable "confluent_kafka_cluster" {
  description = "the name of the cluster"
  type        = string

}

variable "api_key_resource_scope" {
  description = "Resource scope for API key"
  type        = string
  default     = "Cloud Resource Management"
  validation {
    condition     = contains(["Cloud Resource Management", "Kafka Cluster", "Schema Registry", "ksqlDB Cluster", "Flink Region"], var.api_key_resource_scope)
    error_message = "The resource scope must be one of 'Cloud Resource Management', 'Kafka Cluster', 'Schema Registry', 'ksqlDB Cluster', or 'Flink Region'."
  }
}

variable "confluent_kafka_flink" {
  description = "the name of flink"
  type        = string

}

variable "confluent_kafka_ksqldb" {
  description = "the name of the ksql db cluster"
  type        = string

}

