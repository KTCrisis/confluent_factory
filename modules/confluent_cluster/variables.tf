variable "confluent_kafka_environment" {
  description = "the confluent environment name"
  type        = string

}

variable "cluster_name" {
  description = "The confluent cluster name"
  type        = string

}

variable "availability_zone" {
  description = "The availability zone configuration of the Kafka cluster"
  type        = string
  validation {
    condition     = contains(["SINGLE_ZONE", "MULTI_ZONE", "LOW", "HIGH"], var.availability_zone)
    error_message = "The availability zone configuration must be one of 'SINGLE_ZONE', 'MULTI_ZONE', 'LOW' or 'HIGH'."
  }
}

variable "cloud_provider" {
  description = "The cloud service provider that runs the Kafka cluster."
  type        = string
  validation {
    condition     = contains(["AWS", "AZURE", "GCP"], var.cloud_provider)
    error_message = "The cloud service provider must be one of 'AWS', 'AZURE', or 'GCP'."
  }

}

variable "region" {
  description = "The cloud service provider region where the Kafka cluster is running."
  type        = string

}

variable "cluster_type" {
  description = "the cluster type"
  type        = string
  validation {
    condition     = contains(["basic", "standard", "enterprise", "freight", "dedicated"], var.cluster_type)
    error_message = "The cluster type must be one of 'basic', 'standard', 'enterprise', 'freight', or 'dedicated'."
  }

}


variable "cku" {
  description = "the CKU number of dedicated cluster"
  type        = number

}

variable "confluent_kafka_network" {
  description = "The confluent network name"
  type        = string
}









