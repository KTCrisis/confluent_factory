
variable "confluent_kafka_environment" {
  description = "The Confluent environment ID or name"
  type        = string
}
variable "flink_name" {
  description = "The confluent flink name"
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

variable "max_cfu" {
  description = "Compute Flink Unit"
  type        = number
  default     = 5
}

