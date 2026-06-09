resource "azurerm_storage_account" "storage" {
  name                     = "nexabankstore${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  public_network_access_enabled = false
}

resource "azurerm_storage_container" "kyc" {
  name                  = "kyc-documents"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed-and-validated-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_vnet_link" {
  name                  = "blob-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_private_endpoint" "blob_pe" {
  name                = "nexabank-storage-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "blob-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
