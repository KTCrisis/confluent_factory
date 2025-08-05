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


# resource "confluent_private_link_access" "gcp_private_link_access" {
#   for_each = { for connection in var.connection_list : connection.connection_name => connection_ }

#   display_name = each.value.connection_name
#   gcp {
#     project = each.value.connection_project_id
#   }
#   environment {
#     id = data.confluent_environment.environment.id
#   }
#   network {
#     id = confluent_network.private-service-connect[0].id
#   }
# }

# resource "confluent_network" "peering" {
#   count = var.connection_types == "PEERING" ? 1: 0
#   display_name     = var.confluent_kafka_network
#   cloud            = var.cloud_provider
#   region           = var.region
#   cidr             = var.cidr
#   connection_types = ["PEERING"]
#   environment {
#     id = data.confluent_network.environment.id
#   }

# lifecycle {
#   prevent_destroy = true
# }
# }