output "resource_group_name" {
  value = azurerm_resource_group.platform.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.platform.name
}

output "key_vault_name" {
  value = azurerm_key_vault.platform.name
}

output "container_registry_login_server" {
  value = azurerm_container_registry.platform.login_server
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}
