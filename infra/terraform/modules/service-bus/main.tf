resource "azurerm_servicebus_namespace" "sb" {
  name                = var.sb_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_servicebus_queue" "sb_queue" {
  name         = "kyc-notifications"
  namespace_id = azurerm_servicebus_namespace.sb.id
}
