variable "kafka_cluster_name" {
  type = string
}

variable "kafka_cluster_environment" {
  type = string
}

variable "kafka_topic_name" {
  type = string
}

variable "kafka_topic_partitions" {
  type = number
}

variable "kafka_topic_retention_ms" {
  type = number
}

variable "kafka_cluster_api_key" {
  type = string
}

variable "kafka_cluster_api_secret" {
  type = string
}

variable "kafka_topic_cleanup_policy" {
  type = string
}
