resource "azurerm_private_endpoint" "pe" {
  name                = var.pe_name
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.pe_name}-connection"
    private_connection_resource_id = var.target_resource_id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }
}

