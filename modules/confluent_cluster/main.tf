data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

data "confluent_network" "network" {
  count        = var.confluent_kafka_network == "" ? 0 : 1
  display_name = var.confluent_kafka_network
  environment {
    id = data.confluent_environment.environment.id
  }
}

resource "confluent_kafka_cluster" "cluster" {
  display_name = var.cluster_name
  availability = var.availability_zone
  cloud        = var.cloud_provider
  region       = var.region

  dynamic "basic" {
    for_each = var.cluster_type == "basic" ? ["enabled"] : []
    content {}
  }
  dynamic "standard" {
    for_each = var.cluster_type == "standard" ? ["enabled"] : []
    content {}
  }
  dynamic "enterprise" {
    for_each = var.cluster_type == "enterprise" ? ["enabled"] : []
    content {}
  }
  dynamic "dedicated" {
    for_each = var.cluster_type == "dedicated" ? ["enabled"] : []
    content {
      cku = var.cku
    }
  }

  environment {
    id = data.confluent_environment.environment.id
  }


  dynamic "network" {
    for_each = var.confluent_kafka_network == "" ? [] : ["enabled"]
    content {
      id = data.confluent_network.network[0].id
    }
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}
