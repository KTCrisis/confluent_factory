data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment_name
}

data "confluent_kafka_cluster" "cluster" {
  environment {
    id = data.confluent_environment.environment.id
  }
  display_name = var.kafka_cluster_name
}

data "confluent_schema_registry_cluster" "schema_registry_cluster" {
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_service_account" "service_account" {
  display_name = var.ksql_service_account_name
}

resource "confluent_ksql_cluster" "ksql_cluster" {
  display_name = var.ksql_cluster_name
  csu          = var.csu

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  credential_identity {
    id = data.confluent_service_account.service_account.id
  }

  environment {
    id = data.confluent_environment.environment.id
  }

}
