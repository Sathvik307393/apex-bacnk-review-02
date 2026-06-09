resource "azurerm_private_dns_zone" "postgres" {
  name                = "nexabank.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_vnet_link" {
  name                  = "postgres-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "nexabank-postgres-${random_string.suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "16"
  delegated_subnet_id    = var.db_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  administrator_login    = var.postgres_admin_user
  administrator_password = var.postgres_admin_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  
  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres_vnet_link]
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
