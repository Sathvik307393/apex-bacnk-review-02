output "id" {
  value       = azurerm_key_vault.kv.id
  description = "The ID of the key vault"
}
output "vault_uri" {
  value       = azurerm_key_vault.kv.vault_uri
  description = "The URI of the key vault"
}

