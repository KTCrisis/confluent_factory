variable "confluent_kafka_environment" {
  description = "the confluent environment name"
  type        = string

}

variable "confluent_kafka_network" {
  description = "The confluent network name"
  type        = string
}


variable "customer_project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "connection_name" {
  description = "The name of the Ingress connection"
  type        = string
}



