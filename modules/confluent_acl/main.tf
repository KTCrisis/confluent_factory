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

data "confluent_ksql_cluster" "ksqldb" {
  display_name = var.confluent_kafka_ksqldb
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]
}

data "confluent_schema_registry_cluster" "schema_registry_cluster" {
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_service_account" "service_account_app" {
  display_name = var.service_account_name
}

resource "confluent_kafka_acl" "app-consumer-read-on-topic" {
  count = var.service_account_type_acl == "consumer-topic" ? 1 : 0

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  resource_type = "TOPIC"
  resource_name = var.resource_name
  pattern_type  = "PREFIXED"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
}


resource "confluent_kafka_acl" "app_producer_write_on_topic" {
  count = var.service_account_type_acl == "producer-topic" ? 1 : 0
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id

  }

  resource_type = "TOPIC"
  resource_name = var.resource_name
  pattern_type  = "PREFIXED"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
}


resource "confluent_kafka_acl" "app-consumer-read-on-group" {
  count = var.service_account_type_acl == "consumer-topic" ? 1 : 0

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id

  }
  resource_type = "GROUP"
  resource_name = "${data.confluent_service_account.service_account_app.display_name}_group"
  pattern_type  = "PREFIXED"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
  depends_on = [confluent_kafka_acl.app-consumer-read-on-topic]
}

resource "confluent_role_binding" "app-consumer-schema_registry" {
  count = var.service_account_type_acl == "consumer-schema_registry" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account_app.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${data.confluent_schema_registry_cluster.schema_registry_cluster.resource_name}/subject=${var.resource_name}*"
  depends_on  = [data.confluent_schema_registry_cluster.schema_registry_cluster]
}


resource "confluent_role_binding" "app-producer-schema_registry" {
  count = var.service_account_type_acl == "consumer-schema_registry" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account_app.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${data.confluent_schema_registry_cluster.schema_registry_cluster.resource_name}/subject=${var.resource_name}*"
  depends_on  = [data.confluent_schema_registry_cluster.schema_registry_cluster]
}

################### kstream create acl for topics ###########################
resource "confluent_kafka_acl" "app_create_kstream_topics" {
  count = var.service_account_type_acl == "kstream" ? 1 : 0
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id

  }

  resource_type = "TOPIC"
  resource_name = "${data.confluent_service_account.service_account_app.display_name}_group"
  pattern_type  = "PREFIXED"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
}

############## ksql acls ########################

#Provisoire
resource "confluent_role_binding" "app_client_rbac_ksqldb" {
  count = var.service_account_type_acl == "ksql" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account_app.id}"
  role_name   = "KsqlAdmin"
  crn_pattern = data.confluent_ksql_cluster.ksqldb.resource_name
  depends_on  = [data.confluent_ksql_cluster.ksqldb]
}

resource "confluent_kafka_acl" "ksql_deny_delete_topic" {
  count = var.service_account_type_acl == "ksql" ? 1 : 0
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "DENY"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
}

resource "confluent_kafka_acl" "ksql_deny_create_topic" {
  count = var.service_account_type_acl == "ksql" ? 1 : 0
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "DENY"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
}

# # ACLs Kafka minimales pour utiliser ksqlDB (produce/consume uniquement)

# # 1. DESCRIBE sur le cluster (obligatoire pour les métadonnées)
# resource "confluent_kafka_acl" "ksql_describe_cluster" {
#   count = var.service_account_type_acl == "ksql" ? 1 : 0

#   kafka_cluster {
#     id = data.confluent_kafka_cluster.cluster.id
#   }

#   resource_type = "CLUSTER"
#   resource_name = "kafka-cluster"
#   pattern_type  = "LITERAL"
#   principal     = "User:${data.confluent_service_account.service_account_app.id}"
#   host          = "*"
#   operation     = "DESCRIBE"
#   permission    = "ALLOW"
#   rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

#   credentials {
#     key    = var.kafka_cluster_api_key
#     secret = var.kafka_cluster_api_secret
#   }
# }

# # 2. READ sur votre topic d'entrée
# resource "confluent_kafka_acl" "ksql_read_input_topic" {
#   count = var.service_account_type_acl == "ksql" ? 1 : 0

#   kafka_cluster {
#     id = data.confluent_kafka_cluster.cluster.id
#   }

#   resource_type = "TOPIC"
# resource_name = "*"
# pattern_type  = "LITERAL"
#   principal     = "User:${data.confluent_service_account.service_account_app.id}"
#   host          = "*"
#   operation     = "READ"
#   permission    = "ALLOW"
#   rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

#   credentials {
#     key    = var.kafka_cluster_api_key
#     secret = var.kafka_cluster_api_secret
#   }
# }

# # 3. DESCRIBE sur votre topic d'entrée
# resource "confluent_kafka_acl" "ksql_describe_input_topic" {
#   count = var.service_account_type_acl == "ksql" ? 1 : 0

#   kafka_cluster {
#     id = data.confluent_kafka_cluster.cluster.id
#   }

#   resource_type = "TOPIC"
#   resource_name = "*"
#   pattern_type  = "LITERAL"
#   principal     = "User:${data.confluent_service_account.service_account_app.id}"
#   host          = "*"
#   operation     = "DESCRIBE"
#   permission    = "ALLOW"
#   rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

#   credentials {
#     key    = var.kafka_cluster_api_key
#     secret = var.kafka_cluster_api_secret
#   }
# }

# # 4. READ sur les consumer groups ksqlDB
# resource "confluent_kafka_acl" "ksql_read_consumer_groups" {
#   count = var.service_account_type_acl == "ksql" ? 1 : 0

#   kafka_cluster {
#     id = data.confluent_kafka_cluster.cluster.id
#   }

#   resource_type = "GROUP"
#   resource_name = "_confluent-ksql-${data.confluent_ksql_cluster.ksqldb.topic_prefix}"
#   pattern_type  = "PREFIXED"
#   principal     = "User:${data.confluent_service_account.service_account_app.id}"
#   host          = "*"
#   operation     = "READ"
#   permission    = "ALLOW"
#   rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

#   credentials {
#     key    = var.kafka_cluster_api_key
#     secret = var.kafka_cluster_api_secret
#   }
# }

# # 5. Si vous voulez écrire dans un topic de sortie
# resource "confluent_kafka_acl" "ksql_write_output_topic" {
#   count = var.service_account_type_acl == "ksql" ? 1 : 0

#   kafka_cluster {
#     id = data.confluent_kafka_cluster.cluster.id
#   }

#   resource_type = "TOPIC"
#   resource_name = "*"  # Remplacez par votre topic de sortie
#   pattern_type  = "LITERAL"
#   principal     = "User:${data.confluent_service_account.service_account_app.id}"
#   host          = "*"
#   operation     = "WRITE"
#   permission    = "ALLOW"
#   rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

#   credentials {
#     key    = var.kafka_cluster_api_key
#     secret = var.kafka_cluster_api_secret
#   }
# }

############## flink acls

resource "confluent_role_binding" "app-manager-flink-developer" {
  count = var.service_account_type_acl == "flink" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account_app.id}"
  role_name   = "FlinkDeveloper"
  crn_pattern = data.confluent_environment.environment.resource_name

  depends_on = [data.confluent_schema_registry_cluster.schema_registry_cluster]

}

resource "confluent_kafka_acl" "app-consumer-flink_read-on-topic" {
  count = var.service_account_type_acl == "flink" ? 1 : 0

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  resource_type = "TOPIC"
  resource_name = var.resource_name
  pattern_type  = "PREFIXED"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
}

resource "confluent_role_binding" "app-consumer-flink-schema_registry_Developer_Read" {
  count = var.service_account_type_acl == "flink" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account_app.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${data.confluent_schema_registry_cluster.schema_registry_cluster.resource_name}/subject=${var.resource_name}*"
  depends_on  = [data.confluent_schema_registry_cluster.schema_registry_cluster]
}

resource "confluent_kafka_acl" "app-consumer-flink-read-on-group" {
  count = var.service_account_type_acl == "flink" ? 1 : 0

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id

  }
  resource_type = "GROUP"
  resource_name = "${data.confluent_service_account.service_account_app.display_name}_group"
  pattern_type  = "PREFIXED"
  principal     = "User:${data.confluent_service_account.service_account_app.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = var.kafka_cluster_api_key
    secret = var.kafka_cluster_api_secret
  }
  depends_on = [confluent_kafka_acl.app-consumer-read-on-topic]
}