data "azurerm_client_config" "current" {}

locals {
  unique_suffix  = lower(substr(replace(data.azurerm_client_config.current.subscription_id, "-", ""), 0, 8))
  acr_name       = "northstaraks${local.unique_suffix}"
  key_vault_name = "northstarakskv${local.unique_suffix}"
  workload_name  = "northstar-aks-workload"
}

resource "azurerm_container_registry" "platform" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = azurerm_resource_group.platform.tags
}

resource "azurerm_key_vault" "platform" {
  name                       = local.key_vault_name
  resource_group_name        = azurerm_resource_group.platform.name
  location                   = azurerm_resource_group.platform.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  network_acls {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = ["128.24.198.36/32", "20.175.221.129/32"]
  }



  tags = azurerm_resource_group.platform.tags
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = local.workload_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  tags = azurerm_resource_group.platform.tags
}

resource "azurerm_role_assignment" "deployer_key_vault_secret_officer" {
  scope                = azurerm_key_vault.platform.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "workload_key_vault_secret_user" {
  scope                = azurerm_key_vault.platform.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_kubernetes_cluster" "platform" {
  name                = var.aks_name
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix          = "northstaraks-${local.unique_suffix}"
  sku_tier            = "Free"

  api_server_access_profile {
    authorized_ip_ranges = ["128.24.198.36/32"]
  }

  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = true

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    auto_scaling_enabled         = true
    min_count                    = 1
    max_count                    = 1
    os_disk_size_gb              = 30
    only_critical_addons_enabled = true
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }

    node_labels = {
      "northstar.io/purpose" = "system"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    load_balancer_sku   = "standard"
  }

  tags = azurerm_resource_group.platform.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.platform.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.platform.kubelet_identity[0].object_id
}

resource "azurerm_federated_identity_credential" "workload" {
  name                      = "workloads-secret-reader"
  user_assigned_identity_id = azurerm_user_assigned_identity.workload.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.platform.oidc_issuer_url
  subject                   = "system:serviceaccount:workloads:secret-reader"
}
