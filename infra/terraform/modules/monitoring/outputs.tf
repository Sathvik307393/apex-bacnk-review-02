output "id" {
  value       = azurerm_application_insights.appinsights.id
  description = "The ID of the Application Insights instance"
}
output "instrumentation_key" {
  value       = azurerm_application_insights.appinsights.instrumentation_key
  description = "The instrumentation key of the Application Insights instance"
  sensitive   = true
}
output "connection_string" {
  value       = azurerm_application_insights.appinsights.connection_string
  description = "The connection string of the Application Insights instance"
  sensitive   = true
}

