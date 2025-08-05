data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

data "confluent_service_account" "service_account" {
  display_name = var.service_account_name

}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.confluent_kafka_cluster
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]
}

data "confluent_flink_compute_pool" "flink_compute_pool" {

  count = var.api_key_resource_scope == "Flink Region" ? 1 : 0

  display_name = var.confluent_kafka_flink
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_flink_region" "flink_region" {
  count = var.api_key_resource_scope == "Flink Region" ? 1 : 0

  cloud  = data.confluent_flink_compute_pool.flink_compute_pool[0].cloud
  region = data.confluent_flink_compute_pool.flink_compute_pool[0].region
}


data "confluent_ksql_cluster" "ksql_db" {

  count        = var.api_key_resource_scope == "ksqlDB Cluster" ? 1 : 0
  display_name = var.confluent_kafka_ksqldb
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


resource "confluent_api_key" "Cloud_Resource_Management_api_key" {

  count        = var.api_key_resource_scope == "Cloud Resource Management" ? 1 : 0
  display_name = "${data.confluent_service_account.service_account.display_name} - Cloud Resource Management API Key"
  description  = "Cloud Resource Management Key that is owned by '${data.confluent_service_account.service_account.display_name}' service account"

  owner {
    id          = data.confluent_service_account.service_account.id
    api_version = data.confluent_service_account.service_account.api_version
    kind        = data.confluent_service_account.service_account.kind
  }

  lifecycle {
    ignore_changes = all
  }


}

resource "confluent_api_key" "Kafka_Cluster_api_key" {

  count        = var.api_key_resource_scope == "Kafka Cluster" ? 1 : 0
  display_name = "${data.confluent_service_account.service_account.display_name} - Kafka Cluster API Key"
  description  = "Kafka Cluster API Key that is owned by '${data.confluent_service_account.service_account.display_name}' service account"
  owner {
    id          = data.confluent_service_account.service_account.id
    api_version = data.confluent_service_account.service_account.api_version
    kind        = data.confluent_service_account.service_account.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }
  disable_wait_for_ready = true

  lifecycle {
    ignore_changes = all
  }

}

resource "confluent_api_key" "Flink_Region_api_key" {

  count        = var.api_key_resource_scope == "Flink Region" ? 1 : 0
  display_name = "${data.confluent_service_account.service_account.display_name} - Flink Region API Key"
  description  = "Flink Region API Key that is owned by '${data.confluent_service_account.service_account.display_name}' service account"

  owner {
    id          = data.confluent_service_account.service_account.id
    api_version = data.confluent_service_account.service_account.api_version
    kind        = data.confluent_service_account.service_account.kind
  }

  managed_resource {
    id          = data.confluent_flink_region.flink_region[0].id
    api_version = data.confluent_flink_region.flink_region[0].api_version
    kind        = data.confluent_flink_region.flink_region[0].kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }

  lifecycle {
    ignore_changes = all
  }
}


resource "confluent_api_key" "ksqlDB_Cluster_api_key" {

  count        = var.api_key_resource_scope == "ksqlDB Cluster" ? 1 : 0
  display_name = "${data.confluent_service_account.service_account.display_name} - ksqlDB Cluster API Key"
  description  = "ksqlDB Cluster API Key that is owned by '${data.confluent_service_account.service_account.display_name}' service account"

  owner {
    id          = data.confluent_service_account.service_account.id
    api_version = data.confluent_service_account.service_account.api_version
    kind        = data.confluent_service_account.service_account.kind
  }

  managed_resource {
    id          = data.confluent_ksql_cluster.ksql_db[0].id
    api_version = data.confluent_ksql_cluster.ksql_db[0].api_version
    kind        = data.confluent_ksql_cluster.ksql_db[0].kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "confluent_api_key" "Schema_Registry_api_key" {

  count        = var.api_key_resource_scope == "Schema Registry" ? 1 : 0
  display_name = "${data.confluent_service_account.service_account.display_name} - Schema Registry API Key"
  description  = "Schema Registry API Key that is owned by '${data.confluent_service_account.service_account.display_name}' service account"

  owner {
    id          = data.confluent_service_account.service_account.id
    api_version = data.confluent_service_account.service_account.api_version
    kind        = data.confluent_service_account.service_account.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.schema_registry.id
    api_version = data.confluent_schema_registry_cluster.schema_registry.api_version
    kind        = data.confluent_schema_registry_cluster.schema_registry.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }

  lifecycle {
    ignore_changes = all
  }

}