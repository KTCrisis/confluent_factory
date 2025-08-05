variable "service_account_name" {
  type        = string
  description = "the service account name"
}


variable "confluent_kafka_environment" {
  description = "the confluent environment name"
  type        = string

}

variable "confluent_kafka_cluster" {
  description = "the name of the cluster"
  type        = string

}

variable "confluent_kafka_ksqldb" {
  description = "the name of the ksqldb cluster"
  type        = string

}


variable "resource_name" {
  type        = string
  description = "the kafka resource name"

}


variable "kafka_cluster_api_key" {
  type = string
}

variable "kafka_cluster_api_secret" {
  type = string
}

variable "service_account_type_acl" {
  type = string

}

