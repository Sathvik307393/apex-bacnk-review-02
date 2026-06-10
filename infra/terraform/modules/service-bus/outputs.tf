output "id" {
  value = azurerm_servicebus_namespace.sb.id
}
output "primary_connection_string" {
  value     = azurerm_servicebus_namespace.sb.default_primary_connection_string
  sensitive = true
}
output "processing_results_queue_name" {
  value = azurerm_servicebus_queue.kyc_processing_results.name
}
