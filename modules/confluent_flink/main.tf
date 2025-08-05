data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

resource "confluent_flink_compute_pool" "flink_pool" {

  display_name = var.flink_name
  cloud        = var.cloud_provider
  region       = var.region
  max_cfu      = var.max_cfu
  environment {
    id = data.confluent_environment.environment.id
  }
}
