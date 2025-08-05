locals {

  config               = yamldecode(file(var.CONFIG_FILE))
  topics               = try(local.config.resources.topics, [])
  topic_cleanup_policy = try(local.topics[0].cleanup_policy, "delete")
  project              = try(local.config.project.name, "")
  environment          = try(local.config.project.environment, "")
  team                 = try(local.config.project.team, "")
  domain               = try(local.config.project.domain, "")
  cost_center          = try(local.config.project.cost_center, "")
  owner                = try(local.config.project.owner, "")
  cluster              = try(local.config.project.cluster, "")
  schema_registry      = try(local.config.resources.schema_registry, [])
  connectors           = try(local.config.resources.connectors, {})
  acl                  = try(local.config.resources.acl, {})
  env_suffix           = split("-", local.environment)[length(split("-", local.environment)) - 1]
  flink_statements     = try(local.config.resources.flink_statements, {})


  kafka_cluster_api_key = (
    local.env_suffix == "debug" ? var.kafka_cluster_api_key_debug :
    local.env_suffix == "dev" ? var.kafka_cluster_api_key_dev :
    local.env_suffix == "ope" ? var.kafka_cluster_api_key_ope :
    local.env_suffix == "sta" ? var.kafka_cluster_api_key_sta :
    local.env_suffix == "int" ? var.kafka_cluster_api_key_int :
    ""
  )

  kafka_cluster_api_secret = (
    local.env_suffix == "debug" ? var.kafka_cluster_api_secret_debug :
    local.env_suffix == "dev" ? var.kafka_cluster_api_secret_dev :
    local.env_suffix == "ope" ? var.kafka_cluster_api_secret_ope :
    local.env_suffix == "sta" ? var.kafka_cluster_api_secret_sta :
    local.env_suffix == "int" ? var.kafka_cluster_api_secret_int :
    ""
  )

  kafka_schema_registry_api_key = (

    local.env_suffix == "debug" ? var.kafka_schema_registry_api_key_debug :
    local.env_suffix == "dev" ? var.kafka_schema_registry_api_key_dev :
    local.env_suffix == "ope" ? var.kafka_schema_registry_api_key_ope :
    local.env_suffix == "sta" ? var.kafka_schema_registry_api_key_sta :
    local.env_suffix == "int" ? var.kafka_schema_registry_api_key_int :
    ""
  )

  kafka_schema_registry_api_secret = (
    local.env_suffix == "debug" ? var.kafka_schema_registry_api_secret_debug :
    local.env_suffix == "dev" ? var.kafka_schema_registry_api_secret_dev :
    local.env_suffix == "ope" ? var.kafka_schema_registry_api_secret_ope :
    local.env_suffix == "sta" ? var.kafka_schema_registry_api_secret_sta :
    local.env_suffix == "int" ? var.kafka_schema_registry_api_secret_int :
    ""
  )

  client_service_account = {
    name  = "SA-${local.project}-client-${local.environment}",
    scope = "Kafka Cluster"
  }

  schema_registry_service_account = {
    name  = "SA-${local.project}-schema_registry-${local.environment}",
    scope = "Schema Registry"
  }

  ksql_client_service_account = {
    name  = "SA-${local.project}-ksql-client-${local.environment}",
    scope = "ksqlDB Cluster"
  }

  flink_client_service_account = {
    name  = "SA-${local.project}-flink-client-${local.environment}",
    scope = "Flink Region"
  }


  service_accounts = local.topics != [] ? concat(
    [local.client_service_account],
    [local.schema_registry_service_account],
    [local.flink_client_service_account],
  [local.ksql_client_service_account]) : []


  consumer_topic_list = flatten([
    for prefix in try(local.acl.acl_to_consume.topics_prefixes, []) : {
      service_account_name     = local.client_service_account.name
      resource_name            = prefix
      service_account_type_acl = "consumer-topic"
      # service_account_type_rbac = ["topic_DeveloperRead", "consumer_group_DeveloperRead"]
    }
  ])


  producer_topic_list = flatten([
    for prefix in try(local.acl.acl_to_produce.topics_prefixes, []) : {
      service_account_name     = local.client_service_account.name
      resource_name            = prefix
      service_account_type_acl = "producer-topic"
      # service_account_type_rbac = ["topic_DeveloperWrite"]
    }
  ])

  ksql_consumer_topic_list = flatten([
    for prefix in try(local.acl.acl_to_consume.topics_prefixes, []) : {
      service_account_name     = local.ksql_client_service_account.name
      resource_name            = prefix
      service_account_type_acl = "consumer-topic"
      # service_account_type_rbac = ["topic_DeveloperRead", "consumer_group_DeveloperRead"]
    }
  ])


  ksql_producer_topic_list = flatten([
    for prefix in try(local.acl.acl_to_produce.topics_prefixes, []) : {
      service_account_name     = local.ksql_client_service_account.name
      resource_name            = prefix
      service_account_type_acl = "producer-topic"
      # service_account_type_rbac = ["topic_DeveloperWrite"]
    }
  ])

  topic_schema_registry_list = distinct(
    concat(
      try(local.acl.acl_to_produce.topics_prefixes, []),
      try(local.acl.acl_to_consume.topics_prefixes, [])
    )
  )


  consumer_schema_registry_list = flatten([
    for prefix in try(local.topic_schema_registry_list, []) : {
      service_account_name     = local.schema_registry_service_account.name
      resource_name            = "${prefix}"
      service_account_type_acl = "consumer-schema_registry"
      # service_account_type_rbac = ["schema_registry_DeveloperRead"]
    }
  ])

  ksql_acls_list = flatten([
    for prefix in try(local.acl.acl_to_produce.topics_prefixes, []) : {
      service_account_name     = local.ksql_client_service_account.name
      resource_name            = prefix
      service_account_type_acl = "ksql"
      # service_account_type_rbac = ["topic_DeveloperRead", "topic_DeveloperWrite", "consumer_group_DeveloperRead"]
    }
  ])

  kstream_create_topic_acl_list = [
    {
      service_account_name     = local.client_service_account.name
      resource_name            = "${local.client_service_account.name}_group"
      service_account_type_acl = "kstream"
      # service_account_type_rbac = ["topic_DeveloperRead", "topic_DeveloperWrite", "consumer_group_DeveloperRead"]
    }
  ]


  flink_acls_list = [
    for prefix in try(local.topic_schema_registry_list, []) : {
      service_account_name     = local.flink_client_service_account.name
      resource_name            = "${prefix}"
      service_account_type_acl = "flink"
      # service_account_type_rbac = ["topic_DeveloperRead", "topic_DeveloperWrite", "consumer_group_DeveloperRead"]
    }
  ]


  application = concat(

    local.producer_topic_list,
    local.consumer_topic_list,
    local.consumer_schema_registry_list,
    local.ksql_acls_list,
    local.kstream_create_topic_acl_list,
    local.flink_acls_list

  )

  config_source_connector = flatten([
    for source_connector in try(local.connectors.source, []) : {
      connector_name            = source_connector.name
      config_sensitive_path     = "${source_connector.path}/config_sensitive.json"
      config_non_sensitive_path = "${source_connector.path}/config_nonsensitive.json"
    }
  ])

  config_sink_connector = flatten([
    for sink_connector in try(local.connectors.sink, []) : {
      connector_name            = sink_connector.name
      config_sensitive_path     = "${sink_connector.path}/config_sensitive.json"
      config_non_sensitive_path = "${sink_connector.path}/config_nonsensitive.json"

    }
  ])

  config_connectors = concat(
    local.config_source_connector,
    local.config_sink_connector

  )

  desired_tags = {
    team        = "${local.team}"
    cost_center = local.cost_center
    domain      = "${local.domain}"
    owner       = "${local.owner}"
    environment = "${element(split("-", local.environment), length(split("-", local.environment)) - 1)}"
  }

  normalized_tags = {
    for key, value in local.desired_tags :
    key => "${value}_${key}"
  }


}

module "topic" {
  source   = "./modules/confluent_topics"
  for_each = { for topic in local.topics : topic.name => topic }

  kafka_cluster_name         = local.cluster
  kafka_cluster_environment  = local.environment
  kafka_cluster_api_key      = local.kafka_cluster_api_key
  kafka_cluster_api_secret   = local.kafka_cluster_api_secret
  kafka_topic_name           = each.value.name
  kafka_topic_partitions     = try(each.value.partitions, 3)
  kafka_topic_retention_ms   = try(each.value.retention_ms, 604800000)  # 7 days
  kafka_topic_cleanup_policy = try(each.value.cleanup_policy, "delete") # Pass cleanup policy here

}

module "service_account" {
  source               = "./modules/confluent_service_account"
  for_each             = { for idx, service_account in local.service_accounts : "${service_account.name}-${idx}" => service_account }
  service_account_name = each.value.name

  depends_on = [module.topic]

}

module "api_key" {
  source = "./modules/confluent_api_key"
  for_each = { for service_account in local.service_accounts :
  "${service_account.name}-api-key" => service_account }
  service_account_name        = each.value.name
  api_key_resource_scope      = each.value.scope
  confluent_kafka_environment = local.environment
  confluent_kafka_cluster     = local.cluster
  confluent_kafka_flink       = (each.value.scope == "Flink Region" ? "flink-${local.environment}" : "")
  confluent_kafka_ksqldb      = (each.value.scope == "ksqlDB Cluster" ? "ksqldb-${local.environment}" : "")

  depends_on = [module.service_account]
}

module "acl" {
  source   = "./modules/confluent_acl"
  for_each = { for app in local.application : "${app.service_account_name}-${app.resource_name}-${app.service_account_type_acl}" => app }

  service_account_type_acl    = each.value.service_account_type_acl
  resource_name               = each.value.resource_name
  service_account_name        = each.value.service_account_name
  confluent_kafka_environment = local.environment
  confluent_kafka_cluster     = local.cluster
  confluent_kafka_ksqldb      = "ksqldb-${local.environment}"
  kafka_cluster_api_key       = local.kafka_cluster_api_key
  kafka_cluster_api_secret    = local.kafka_cluster_api_secret

  depends_on = [module.service_account]

}

module "schema_registry" {
  source                           = "./modules/confluent_schema_registry"
  for_each                         = { for schema_registry in local.schema_registry : schema_registry.subject_name => schema_registry }
  subject_name                     = each.value.subject_name
  subject_format                   = try(each.value.subject_format, "")
  schema_path                      = try(each.value.subject_path, "")
  confluent_kafka_environment      = local.environment
  kafka_schema_registry_api_key    = local.kafka_schema_registry_api_key
  kafka_schema_registry_api_secret = local.kafka_schema_registry_api_secret
  schema_references                = try(each.value.schema_references, [])


  depends_on = [module.service_account]
}


module "topic_tags" {
  source   = "./modules/confluent_topic_tags"
  for_each = { for topic in local.topics : topic.name => topic }

  confluent_kafka_environment      = local.environment
  cluster_name                     = local.cluster
  kafka_schema_registry_api_key    = local.kafka_schema_registry_api_key
  kafka_schema_registry_api_secret = local.kafka_schema_registry_api_secret
  topics                           = [each.value]
  tags = {
    for key, value in local.normalized_tags :
    key => value
  }
  depends_on = [
    module.schema_registry,
    module.topic
  ]
}

module "connector" {
  source   = "./modules/confluent_connector"
  for_each = { for connector in local.config_connectors : connector.connector_name => connector }

  connector_name              = each.value.connector_name
  confluent_kafka_environment = local.environment
  confluent_kafka_cluster     = local.cluster
  service_account_name        = local.client_service_account.name
  config_sensitive_file       = each.value.config_sensitive_path
  config_nonsensitive_file    = each.value.config_non_sensitive_path

  depends_on = [module.service_account, module.topic]
}


module "flink_statement" {
  source   = "./modules/confluent_flink_statement"
  for_each = { for statement in local.flink_statements : statement.name => statement }

  flink_compute_pool_name         = "flink-${local.environment}"
  flink_statement_path            = each.value.statement_path
  confluent_kafka_environment     = local.environment
  confluent_kafka_cluster         = local.cluster
  kafka_flink_api_key             = module.api_key["${local.flink_client_service_account.name}-api-key"].Flink_Region_scope.credentials.key
  kafka_flink_api_secret          = module.api_key["${local.flink_client_service_account.name}-api-key"].Flink_Region_scope.credentials.secret
  service_account_flink_developer = local.flink_client_service_account.name


  depends_on = [module.service_account, module.api_key, module.acl]
}





