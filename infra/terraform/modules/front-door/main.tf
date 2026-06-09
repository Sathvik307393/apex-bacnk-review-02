resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = var.frontdoor_name
  resource_group_name = var.rg_name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = var.frontdoor_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
}

resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  name                     = replace(var.custom_domain_name, ".", "-")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  host_name                = var.custom_domain_name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

