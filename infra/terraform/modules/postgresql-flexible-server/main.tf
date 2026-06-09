resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = var.db_server_name
  resource_group_name    = var.rg_name
  location               = var.location
  version                = "16"
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.admin_user
  administrator_password = var.admin_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  # Must be false when using VNet/subnet delegation — was causing the 400 conflict error
  public_network_access_enabled = false
  tags                          = var.tags
}
