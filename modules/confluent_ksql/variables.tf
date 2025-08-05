variable "ksql_cluster_name" {
  description = "KSQLDB cluster name"
  type        = string
}

variable "kafka_cluster_name" {
  description = "Kafka cluster name"
  type        = string
}

variable "ksql_service_account_name" {
  description = "the name of ksqldb service account"
  type        = string
}

variable "confluent_kafka_environment_name" {
  description = "The Confluent environment name"
  type        = string
}

variable "csu" {
  description = "the CSU cost"
  type        = number

}