output "id" { value = azurerm_storage_account.st.id }
output "primary_blob_endpoint" { value = azurerm_storage_account.st.primary_blob_endpoint }
output "name" { value = azurerm_storage_account.st.name }
output "primary_access_key" {
  value     = azurerm_storage_account.st.primary_access_key
  sensitive = true
}
output "primary_connection_string" {
  value     = azurerm_storage_account.st.primary_connection_string
  sensitive = true
}
output "kyc_documents_container_name" {
  value = azurerm_storage_container.kyc_documents.name
}
output "processed_documents_container_name" {
  value = azurerm_storage_container.processed_documents.name
}

