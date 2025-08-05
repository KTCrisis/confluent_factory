resource "confluent_service_account" "service_account" {
  display_name = var.service_account_name
  description  = "this is a descrption of ${var.service_account_name}"
}





