data "confluent_environment" "environment" {
  display_name = var.kafka_cluster_environment
}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.kafka_cluster_name
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]

}

data "confluent_schema_registry_cluster" "schema_registry" {
  environment {
    id = data.confluent_environment.environment.id
  }
  depends_on = [data.confluent_environment.environment]

}

data "confluent_service_account" "service_account" {
  display_name = var.service_account_name
}


# ######### TOPIC SCOPE

resource "confluent_role_binding" "topic-ResourceOwner-role_binding" {
  count = var.service_account_type_rbac == "topic_ResourceOwner" && var.resource_name != null ? 1 : 0
  #   count = var.service_account_type_rbac == "topic_${role_name}" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "ResourceOwner"
  crn_pattern = local.topic_crn_pattern
}

resource "confluent_role_binding" "topic-DeveloperWrite-role_binding" {
  count = var.service_account_type_rbac == "topic_DeveloperWrite" && var.resource_name != null ? 1 : 0
  #   count = var.service_account_type_rbac == "topic_${role_name}" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = local.topic_crn_pattern
}

resource "confluent_role_binding" "topic-DeveloperRead-role_binding" {
  count = var.service_account_type_rbac == "topic_DeveloperRead" && var.resource_name != null ? 1 : 0
  #   count = var.service_account_type_rbac == "topic_${role_name}" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperRead"
  crn_pattern = local.topic_crn_pattern
}

resource "confluent_role_binding" "topic-DeveloperManage-role_binding" {
  count = var.service_account_type_rbac == "topic_DeveloperManage" && var.resource_name != null ? 1 : 0
  #   count = var.service_account_type_rbac == "topic_${role_name}" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperManage"
  crn_pattern = local.topic_crn_pattern
}

# ######### CONSUMER GROUPS SCOPE

resource "confluent_role_binding" "consumer_group-ResourceOwner-role_binding" {
  count = var.service_account_type_rbac == "consumer_group_ResourceOwner" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "ResourceOwner"
  crn_pattern = local.consumer_group_crn_pattern
}

resource "confluent_role_binding" "consumer_group-DeveloperRead-role_binding" {
  count = var.service_account_type_rbac == "consumer_group_DeveloperRead" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperRead"
  crn_pattern = local.consumer_group_crn_pattern
}

resource "confluent_role_binding" "consumer_group-DeveloperManage-role-binding" {
  count = var.service_account_type_rbac == "consumer_group_DeveloperManage" && var.resource_name != null ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperManage"
  crn_pattern = local.consumer_group_crn_pattern
}

# ######### SCHEMA REGISTRY SCOPE

resource "confluent_role_binding" "schema_registry-DeveloperRead-role_binding" {
  count = var.service_account_type_rbac == "schema_registry_DeveloperRead" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperRead"
  crn_pattern = local.schema_registry_crn_pattern
}

resource "confluent_role_binding" "schema_registry-DeveloperWrite-role_binding" {
  count = var.service_account_type_rbac == "schema_registry_DeveloperWrite" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = local.schema_registry_crn_pattern
}

resource "confluent_role_binding" "schema_registry-ResourceOwner-role_binding" {
  count = var.service_account_type_rbac == "schema_registry_ResourceOwner" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "ResourceOwner"
  crn_pattern = local.schema_registry_crn_pattern
}

resource "confluent_role_binding" "schema_registry-DeveloperManage-role_binding" {
  count = var.service_account_type_rbac == "schema_registry_DeveloperManage" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DeveloperManage"
  crn_pattern = local.schema_registry_crn_pattern
}

######### ENVIRONMENT SCOPE

resource "confluent_role_binding" "environment-DataSteward-role_binding" {
  count = var.service_account_type_rbac == "environment_DataSteward" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "DataSteward"
  crn_pattern = local.environnment_crn_pattern
}

######### CLUSTER SCOPE

resource "confluent_role_binding" "environment-CloudClusterAdmin-role_binding" {
  count = var.service_account_type_rbac == "cluster_CloudClusterAdmin" ? 1 : 0

  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = local.cluster_crn_pattern
}

######### KSQL SCOPE

resource "confluent_role_binding" "ksql-EnvironmentAdmin-role_binding" {
  count       = var.service_account_type_rbac == "ksql_EnvironmentAdmin" ? 1 : 0
  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = local.environnment_crn_pattern
}

######### FLINK SCOPE

resource "confluent_role_binding" "flinkd--role_binding" {
  count       = var.service_account_type_rbac == "ksql_EnvironmentAdmin" ? 1 : 0
  principal   = "User:${data.confluent_service_account.service_account.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = local.environnment_crn_pattern
}