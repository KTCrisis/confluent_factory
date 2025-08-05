variable "confluent_kafka_environment" {
  description = "the confluent environment name"
  type        = string

}

variable "subject_name" {
  description = "the subject name of schema registry"
  type        = string

}

variable "subject_format" {
  description = "the subject format of schema registry"
  type        = string
  # default     = "AVRO"
  validation {
    condition     = contains(["AVRO", "PROTOBUF", "JSON"], var.subject_format)
    error_message = "The subject format must be one of 'AVRO', 'PROTOBUF' or 'JSON'."
  }
}

variable "kafka_schema_registry_api_key" {
  type        = string
  description = "Schema Registry API Key for data.confluent_schema_registry"
}

variable "kafka_schema_registry_api_secret" {
  type        = string
  description = "Schema Registry API Secret for data.confluent_schema_registry"
}

variable "schema_path" {
  type        = string
  description = "the path of the schema subject"

}

variable "schema_references" {
  description = "List of schema references"
  type = list(object({
    name         = string
    subject_name = string
    version      = number
  }))
  default = []
}
