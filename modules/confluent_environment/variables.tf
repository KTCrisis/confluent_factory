variable "environment_name" {
  description = "The confluent environment name"
  type        = string

}

variable "stream_governance_package" {
  description = "The package type of stream governance"
  type        = string
  validation {
    condition     = contains(["ESSENTIALS", "ADVANCED"], var.stream_governance_package)
    error_message = "The stream governance package must be one of 'ESSENTIALS', or 'ADVANCED'."
  }

}
