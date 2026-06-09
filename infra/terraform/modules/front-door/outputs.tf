output "id" {
  value       = azurerm_cdn_frontdoor_profile.fd.id
  description = "The ID of the front door"
}
output "endpoint_host_name" {
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
  description = "The hostname of the front door"
}

output "custom_domain_validation_token" {
  value       = azurerm_cdn_frontdoor_custom_domain.custom_domain.validation_token
  description = "The validation token of the custom domain"
}

output "custom_domain_host_name" {
  value       = azurerm_cdn_frontdoor_custom_domain.custom_domain.host_name
  description = "The hostname of the custom domain"
}
