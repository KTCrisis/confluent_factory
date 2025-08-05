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

# variable "topic_name" {
#   type= string

# }

variable "connector_name" {
  type = string
}

variable "config_nonsensitive_file" {
  type = string

}

variable "config_sensitive_file" {
  type = string

}