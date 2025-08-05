data "confluent_organization" "organization" {}

data "confluent_environments" "environments" {}

data "confluent_environment" "environment" {
  for_each = { for id in data.confluent_environments.environments.ids : id => id }
  id       = each.value
}

data "confluent_kafka_cluster" "cluster" {
  for_each     = { for id, cluster in local.cluster_list : "${cluster.cluster_name}" => cluster }
  display_name = each.value.cluster_name
  environment {
    id = each.value.environment_id
  }
}

resource "confluent_group_mapping" "group_mapping" {
  for_each     = local.confluent_group_mapping_list
  display_name = each.key
  description  = "this is a description of ${each.key} group mapping"
  filter       = "\"${each.key}\" in groups"

}

# -----------------------Organisation scope-----------------------------------

locals {
  organization_roles = flatten([
    for group, value in local.confluent_group_mapping_list : [
      for scope, roles in value : [
        for role in roles : {
          group = group
          scope = scope
          role  = role
        }
      ] if scope == "Organization_scope"
    ]
  ])
  organization_roles_map = {
    for idx, role in local.organization_roles :
    "${role.group}-${role.scope}-${role.role}" => role
  }
}

output "organization_roles" {
  value = local.organization_roles


}


resource "confluent_role_binding" "role_binding_organization_scope" {
  for_each = local.organization_roles_map

  role_name   = each.value.role
  principal   = "User:${confluent_group_mapping.group_mapping[each.value.group].id}"
  crn_pattern = data.confluent_organization.organization.resource_name
}

# ------------------Environment scope-------------------------------------

locals {
  environment_list = [for env in data.confluent_environment.environment : {
    display_name  = env.display_name
    resource_name = env.resource_name
  }]

  environment_roles = flatten([
    for group, value in local.confluent_group_mapping_list : [
      for scope, roles in value : [
        for role in roles : [
          for env in local.environment_list : {
            group       = group
            scope       = scope
            role        = role
            env         = env.display_name
            crn_pattern = env.resource_name
          }
        ]
      ] if scope == "Environment_scope"
    ]
  ])
  environment_roles_map = {
    for idx, role in local.environment_roles :
    "${role.group}-${role.scope}-${role.env}-${role.role}" => role
  }
}


output "environment_list" {
  value = { var1 = local.environment_list,
    var2 = local.environment_roles,
    var3 = local.organization_roles,
    var4 = local.environment_roles_map
  }
}



resource "confluent_role_binding" "role_binding_environment_scope" {
  for_each = local.environment_roles_map

  principal   = "User:${confluent_group_mapping.group_mapping[each.value.group].id}"
  role_name   = each.value.role
  crn_pattern = each.value.crn_pattern
}

# ------------------Cluster scope-------------------------------------

locals {

  cluster_list = flatten([
    for details in var.cluster_per_environment_list : [
      for id in details.id : [
        for cluster in details.clusters : [
          {
            environment_id = id
            cluster_name   = cluster
          }
        ]

      ]
    ]
  ])


  cluster_roles = flatten([
    for group, value in local.confluent_group_mapping_list : [
      for scope, roles in value : [
        for role in roles : [
          for info in local.cluster_list : {
            group       = group
            scope       = scope
            role        = role
            env         = info.environment_id
            cluster     = info.cluster_name
            crn_pattern = data.confluent_kafka_cluster.cluster[info.cluster_name].rbac_crn


          }
        ]
      ] if scope == "Cluster_scope"
    ]
  ])
  cluster_roles_map = {
    for info in local.cluster_roles :
    "${info.group}-${info.scope}-${info.cluster}-${info.role}" => info
  }
}

# output "cluster_roles" {
#   value = local.cluster_roles
# }
resource "confluent_role_binding" "role_binding_cluster_scope" {
  for_each = local.cluster_roles_map

  principal   = "User:${confluent_group_mapping.group_mapping[each.value.group].id}"
  role_name   = each.value.role
  crn_pattern = each.value.crn_pattern
}



# ------------------Topic scope-------------------------------------

locals {

  cluster_topic_resource_list = flatten([
    for details in var.cluster_per_environment_list : [
      for id in details.id : [
        for cluster in details.clusters : [
          {
            environment_id = id
            cluster_name   = cluster
          }
        ]
      ]
    ]
  ])

  cluster_topic_roles = flatten([
    for group, value in local.confluent_group_mapping_list : [
      for scope, roles in value : [
        for role in roles : [
          for info in local.cluster_topic_resource_list : {
            group         = group
            scope         = scope
            role          = role
            env           = info.environment_id
            cluster_name  = info.cluster_name
            crn_pattern   = data.confluent_kafka_cluster.cluster[info.cluster_name].rbac_crn
            cluster_id    = data.confluent_kafka_cluster.cluster[info.cluster_name].id
            cluster_type  = data.confluent_kafka_cluster.cluster[info.cluster_name].basic == tolist([{}, ]) ? "basic" : "not_basic"
            resource_name = substr(group, 0, 5) == "CORP_" ? "" : split("_", group)[0]
          }
          if scope == "Topic_scope"
        ]
      ]
    ]
  ])

  cluster_topic_roles_map = {
    for info in local.cluster_topic_roles :
    "${info.group}-${info.scope}-${info.cluster_name}-${info.role}" => info
  }
}

output "cluster_topic_roles" {
  value = local.cluster_topic_roles
}

resource "confluent_role_binding" "role_binding_cluster_topic_scope" {
  for_each = {
    for key, value in local.cluster_topic_roles_map : key => value
    if value.cluster_type != "basic"
  }

  principal   = "User:${confluent_group_mapping.group_mapping[each.value.group].id}"
  role_name   = each.value.role
  crn_pattern = "${each.value.crn_pattern}/kafka=${each.value.cluster_id}/topic=${each.value.resource_name}*"
}

