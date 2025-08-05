data "confluent_organization" "organization" {}

data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.confluent_kafka_cluster
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_flink_compute_pool" "flink_compute_pool" {
  display_name = var.flink_compute_pool_name
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_schema_registry_cluster" "schema_registry" {
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]
}

data "confluent_flink_region" "flink_region" {
  cloud  = data.confluent_flink_compute_pool.flink_compute_pool.cloud
  region = data.confluent_flink_compute_pool.flink_compute_pool.region
}

data "confluent_service_account" "service_account" {
  display_name = var.service_account_flink_developer
}


resource "confluent_flink_statement" "flink_statement" {
  organization {
    id = data.confluent_organization.organization.id
  }
  environment {
    id = data.confluent_environment.environment.id
  }
  compute_pool {
    id = data.confluent_flink_compute_pool.flink_compute_pool.id
  }
  principal {
    id = data.confluent_service_account.service_account.id
  }
  statement = file(var.flink_statement_path)
  properties = {
    "sql.current-catalog"  = data.confluent_environment.environment.display_name
    "sql.current-database" = data.confluent_kafka_cluster.cluster.display_name
  }
  # Use data.confluent_flink_region.main.rest_endpoint for Basic, Standard, public Dedicated Kafka clusters
  # For private networking use
  # data.confluent_flink_region.main.private_rest_endpoint
  # or
  # "https://flink${data.confluent_network.main.endpoint_suffix}"
  rest_endpoint = data.confluent_flink_region.flink_region.rest_endpoint
  credentials {
    key    = var.kafka_flink_api_key
    secret = var.kafka_flink_api_secret
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}
