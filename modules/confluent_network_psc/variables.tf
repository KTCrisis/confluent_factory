variable "confluent_kafka_environment" {
  description = "the confluent environment name"
  type        = string

}

variable "confluent_kafka_network" {
  description = "The confluent network name"
  type        = string
}

variable "cloud_provider" {
  description = "The cloud service provider in which the network exists. "
  type        = string
  validation {
    condition     = contains(["AWS", "GCP", "AZURE"], var.cloud_provider)
    error_message = "Accepted values are: AWS, AZURE, and GCP."
  }
}

variable "region" {
  description = "The cloud provider region where the network exists."
  type        = string
}

variable "connection_types" {
  description = "The list of connection types that may be used with the network."
  type        = string
  validation {
    condition     = contains(["PEERING", "TRANSITGATEWAY", "PRIVATELINK"], var.connection_types)
    error_message = "Accepted connection types are: PEERING, TRANSITGATEWAY, and PRIVATELINK."
  }
}

variable "zones" {
  description = "The 3 availability zones for this network."
  type        = list(string)
}

variable "cidr" {
  description = "The IPv4 CIDR block to be used for the network. Must be /16."
  type        = string
}





