output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
output "principal_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
output "kv_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
}
