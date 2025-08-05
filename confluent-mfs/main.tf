locals {
  config      = try(yamldecode(file("./config.yml")), [])
  environment = try(local.config.environment, [])
  env_suffix  = split("-", local.cluster_info[0].cluster_environment)[length(split("-", local.cluster_info[0].cluster_environment)) - 1]
  network     = try(local.environment[0].cluster.network, "")

  ################ infos ###############################

  flink_info = try(flatten([
    for env in local.environment : (
      can(env.flink) && env.flink != null ?
      [{
        flink_name           = "flink-${env.name}"
        max_cfu              = try(env.flink.max_cfu, 5)
        flink_environment    = try(env.name, "")
        flink_cloud_provider = try(env.cluster.cloud_provider, "")
        flink_region         = try(env.cluster.region, "")
        availability_zone    = try(env.cluster.availability_zone, "")
      }] : []
    )
  ]), [])

  cluster_info = try(flatten([
    for env in local.environment : [
      {
        cluster_environment       = try(env.name, "")
        cluster_name              = try(env.cluster.name, "")
        cluster_type              = try(env.cluster.type, "")
        cluster_cloud_provider    = try(env.cluster.cloud_provider, "")
        cluster_region            = try(env.cluster.region, "")
        cluster_availability_zone = try(env.cluster.availability_zone, "")
        cluster_cku               = try(env.cluster.cku, "0")


      }
    ]
  ]), [])

  network_info = try(flatten([
    for env in local.environment : [
      for network in env.network : {
        network_name             = try(network.name, "")
        network_environment      = try(env.name, "")
        network_connection_types = try(network.connection_types, "")
        network_cloud_provider   = try(network.cloud_provider, "")
        network_region           = try(network.region, "")
        network_zones            = try(network.zones, [])
      }
    ]
  ]), [])

  link_access_info = try(flatten([
    for env in local.environment : [
      for network in env.network : [
        for network_config in network.network_config : {

          environment_name = try(env.name, "")
          network_name     = try(network.name, "")
          connection_name  = try(network_config.ingress_connection_name, "")
          project_id       = try(network_config.project_id, "")

        }
      ]
    ]
  ]), [])



  ########################## Service accounts ############################
  schema_registry_admin_service_account = try(flatten([
    for env in local.environment : [
      {
        name                      = "SA-${env.name}-schema_registry_admin"
        scope                     = "Schema Registry"
        service_account_type_rbac = "environment_DataSteward"
        environment               = env.name
        cluster                   = env.cluster.name
      }
    ]
  ]), [])

  cluster_admin_service_account = try(flatten([
    for env in local.environment : [
      {
        name                      = "SA-${env.name}-${env.cluster.name}-cluster_admin"
        scope                     = "Kafka Cluster"
        service_account_type_rbac = "cluster_CloudClusterAdmin"
        environment               = env.name
        cluster                   = env.cluster.name
      }
    ]
  ]), [])

  ksql_admin_service_account = try(flatten([
    for env in local.environment : [
      {
        name                      = "SA-${env.name}-ksql_admin"
        scope                     = "Cloud Resource Management"
        service_account_type_rbac = "ksql_EnvironmentAdmin"
        environment               = env.name
        cluster                   = env.cluster.name
      }
    ]
  ]), [])


  service_accounts = concat(local.schema_registry_admin_service_account, local.cluster_admin_service_account, local.ksql_admin_service_account)

}

############################# Modules ###########################

module "environment" {
  source   = "../../modules/confluent_environment"
  for_each = { for env in local.environment : env.name => env }

  environment_name          = each.value.name
  stream_governance_package = each.value.stream_governance_package

}

module "cluster" {
  source   = "../../modules/confluent_cluster"
  for_each = { for cluster in local.cluster_info : cluster.cluster_name => cluster }

  cluster_name                = each.value.cluster_name
  cluster_type                = each.value.cluster_type
  cloud_provider              = each.value.cluster_cloud_provider
  region                      = each.value.cluster_region
  availability_zone           = each.value.cluster_availability_zone
  cku                         = each.value.cluster_cku
  confluent_kafka_environment = each.value.cluster_environment
  confluent_kafka_network     = local.network
  depends_on                  = [module.environment, module.network]

}

module "service_account" {
  source   = "../../modules/confluent_service_account"
  for_each = { for service_account in local.service_accounts : service_account.name => service_account.name }

  service_account_name = each.value
  depends_on           = [module.cluster]

}

module "api_key" {
  source = "../../modules/confluent_api_key"
  for_each = { for service_account in local.service_accounts :
  "${service_account.name}-api-key" => service_account }

  service_account_name        = each.value.name
  api_key_resource_scope      = each.value.scope
  confluent_kafka_environment = each.value.environment
  confluent_kafka_cluster     = each.value.cluster
  confluent_kafka_flink       = ""
  confluent_kafka_ksqldb      = ""

  depends_on = [module.service_account, module.role_binding_access_control]
}

module "role_binding_access_control" {
  source = "../../modules/confluent_rolebinding_access_control"
  for_each = { for service_account in local.service_accounts :
  "rbac-${service_account.name}-${service_account.service_account_type_rbac}" => service_account }

  service_account_name      = each.value.name
  service_account_type_rbac = each.value.service_account_type_rbac
  kafka_cluster_environment = each.value.environment
  kafka_cluster_name        = each.value.cluster
  resource_name             = ""

  depends_on = [module.service_account]
}

# module "group_mapping" {
#   source = "../modules/confluent_group_mapping"

#   cluster_per_environment_list = local.cluster_per_environment
#   depends_on = [ module.environment , module.cluster]

# }

module "network" {
  source   = "../../modules/confluent_network_psc"
  for_each = { for network in local.network_info : network.network_name => network }

  confluent_kafka_network     = each.value.network_name
  confluent_kafka_environment = each.value.network_environment
  connection_types            = each.value.network_connection_types
  cloud_provider              = each.value.network_cloud_provider
  region                      = each.value.network_region
  zones                       = each.value.network_zones
  cidr                        = ""

  depends_on = [module.environment]

}

module "network_link_access" {
  source   = "../../modules/confluent_network_link_access"
  for_each = { for link_access in local.link_access_info : "${link_access.network_name}_${link_access.connection_name}" => link_access }

  confluent_kafka_network     = each.value.network_name
  confluent_kafka_environment = each.value.environment_name
  connection_name             = each.value.connection_name
  customer_project_id         = each.value.project_id

  depends_on = [module.network]
}


module "ksql_cluster" {
  for_each = { for env in local.environment : env.name => env
    if try(env.ksql.csu, null) != null && try(env.cluster.name, null) != null
  }

  source                           = "../../modules/confluent_ksql"
  ksql_cluster_name                = "ksqldb-${each.key}"
  kafka_cluster_name               = each.value.cluster.name
  confluent_kafka_environment_name = each.value.name
  csu                              = each.value.ksql.csu
  ksql_service_account_name        = local.ksql_admin_service_account[0].name

  depends_on = [module.service_account, module.environment, module.cluster]
}


module "flink" {
  source   = "../../modules/confluent_flink"
  for_each = { for flink in local.flink_info : flink.flink_name => flink }

  flink_name                  = each.value.flink_name
  confluent_kafka_environment = each.value.flink_environment
  cloud_provider              = each.value.flink_cloud_provider
  region                      = each.value.flink_region
  max_cfu                     = each.value.max_cfu
  availability_zone           = each.value.availability_zone

  depends_on = [module.cluster, module.environment]
}