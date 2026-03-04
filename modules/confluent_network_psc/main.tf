data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}


resource "confluent_network" "private-service-connect" {
  count            = var.connection_types == "PRIVATELINK" ? 1 : 0
  display_name     = var.confluent_kafka_network
  cloud            = var.cloud_provider
  region           = var.region
  connection_types = ["PRIVATELINK"]
  zones            = var.zones
  environment {
    id = data.confluent_environment.environment.id
  }

  dns_config {
    resolution = "PRIVATE"
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}
