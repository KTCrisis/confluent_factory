
variable "cluster_per_environment_list" {
  description = "the list of clusters grouped by environment"
  type        = map(any)
  # default = {
  # # RCI-ope: {
  # # "id": ["env-p8q32"], "clusters": ["IRN-72775-OPE-MZ", "IRN-73207-STA", "IRN-73207-OPE-MZ"]
  # #   } 
  # # dev: {
  # # "id": ["env-z69q03"], "clusters": ["mobilize-dev"]
  # #   }
  # # RCI-dev: {
  # # "id": ["env-51v38"], "clusters": ["cluster_3", "irn-73207-dev", "IRN-72775-DEV", "JK", "cluster_4", "cluster_2", "testCluster"]
  # #   }
  # # RCI-STA: {
  # # "id": ["env-09z5n2"], "clusters": ["IRN-72775-STA"]
  # #   }
  # # RCI-int: {
  # # "id": ["env-w153pw"], "clusters": ["IRN-72775-INT"]
  # #   }
  # }

}

locals {
  # clusters_list = yamldecode(file(""))
  # countries    = ["FR", "DE", "UK", "ES", "IT", "SK", "BR"]
  countries    = ["FR"]
  environments = ["DEV", "PPROD", "PROD"]

  corp_groups = {
    CORP_KFK_ROOT = {
      Organization_scope = ["OrganizationAdmin", "NetworkAdmin"]
      Environment_scope  = ["EnvironmentAdmin"]
    }
    CORP_KFK_ADMIN           = { Cluster_scope = ["CloudClusterAdmin"] }
    CORP_KFK_OPERATION_ADMIN = { Organization_scope = ["AccountAdmin", "BillingAdmin"] }
    CORP_KFK_DEVELOPER       = { Topic_scope = ["DeveloperManage", "DeveloperRead", "DeveloperWrite", "ResourceOwner"] }
    CORP_KFK_VIEWER          = { Organization_scope = ["DataDiscovery"] }
    CORP_KFK_MONITORING      = { Organization_scope = ["MetricsViewer"] }
    CORP_KFK_DATA            = { Environment_scope = ["DataSteward"] }
  }

  country_groups = { for k in setproduct(local.countries, local.environments) :
    "${k[0]}_KFK_DEVELOPER_${k[1]}" => {
      Topic_scope = ["DeveloperManage", "DeveloperRead", "DeveloperWrite", "ResourceOwner"]
    }
  }

  confluent_group_mapping_list = merge(local.corp_groups, local.country_groups)
}


