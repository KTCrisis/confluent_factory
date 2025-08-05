variable "kafka_cluster_name" {
  type = string
}

variable "kafka_cluster_environment" {
  type = string
}

variable "service_account_type_rbac" {
  type = string

}
variable "resource_name" {
  type = string

}

variable "service_account_name" {
  description = "The service account name"
  type        = string
}

locals {

  topic_crn_pattern           = "${data.confluent_kafka_cluster.cluster.rbac_crn}/kafka=${data.confluent_kafka_cluster.cluster.id}/subject=${var.resource_name}"
  consumer_group_crn_pattern  = "${data.confluent_kafka_cluster.cluster.rbac_crn}/kafka=${data.confluent_kafka_cluster.cluster.id}/group=${var.resource_name}"
  schema_registry_crn_pattern = "${data.confluent_schema_registry_cluster.schema_registry.resource_name}/subject=${var.resource_name}"
  environnment_crn_pattern    = data.confluent_environment.environment.resource_name
  cluster_crn_pattern         = data.confluent_kafka_cluster.cluster.rbac_crn
}