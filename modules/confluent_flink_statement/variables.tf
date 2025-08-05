
variable "confluent_kafka_environment" {
  description = "The Confluent environment ID or name"
  type        = string
}

variable "flink_statement_path" {
  type        = string
  description = "the path of the flink statement"

}

variable "kafka_flink_api_key" {
  type        = string
  description = "Flink API Key"

}
variable "kafka_flink_api_secret" {
  type        = string
  description = "Flink API secret"
}

variable "service_account_flink_developer" {
  type        = string
  description = "the name of the flink develoepr service account"
}
variable "flink_compute_pool_name" {
  type        = string
  description = "the name of the flink compute pool"
}

variable "confluent_kafka_cluster" {
  type        = string
  description = "the name of the confluent kafka cluster"

}