data "confluent_environment" "environment" {
  display_name = var.confluent_kafka_environment
}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.confluent_kafka_cluster
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]
}


data "confluent_service_account" "service_account_app" {
  display_name = var.service_account_name
}

resource "confluent_connector" "connector" {
  environment {
    id = data.confluent_environment.environment.id
  }
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  config_sensitive = jsondecode(file(var.config_sensitive_file))
  config_nonsensitive = merge(jsondecode(file(var.config_nonsensitive_file)), # Décode le contenu du fichier JSON en map
    {
      "name"                     = var.connector_name
      "kafka.service.account.id" = data.confluent_service_account.service_account_app.id
    }
  )

  depends_on = [
    data.confluent_environment.environment,
    data.confluent_kafka_cluster.cluster,
    data.confluent_service_account.service_account_app
  ]

  # lifecycle {
  #   prevent_destroy = true
  # }
}
