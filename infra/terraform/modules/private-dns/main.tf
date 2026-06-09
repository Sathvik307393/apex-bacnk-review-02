resource "azurerm_private_dns_zone" "dns" {
  name                = var.dns_name
  resource_group_name = var.rg_name
  tags                = var.tags
}

