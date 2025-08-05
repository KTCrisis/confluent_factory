data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}


data "confluent_network" "private-service-connect" {
  display_name = var.confluent_kafka_network
  environment {
    id = data.confluent_environment.environment.id
  }
}

resource "confluent_private_link_access" "gcp_private_link_access" {

  display_name = var.connection_name
  gcp {
    project = var.customer_project_id
  }
  environment {
    id = data.confluent_environment.environment.id
  }
  network {
    id = data.confluent_network.private-service-connect.id
  }
}
