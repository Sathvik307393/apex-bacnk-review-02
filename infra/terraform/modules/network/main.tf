resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Base /16 + 4 bits = /20 (4096 IPs for Azure CNI Pods)
  address_prefixes = [cidrsubnet(var.address_space[0], 4, 0)]
}

resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Base /16 + 8 bits = /24 (256 IPs for App Gateway)
  address_prefixes = [cidrsubnet(var.address_space[0], 8, 16)]
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Base /16 + 11 bits = /27 (32 IPs for DB)
  address_prefixes = [cidrsubnet(var.address_space[0], 11, 136)]

  delegation {
    name = "fs"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "pe" {
  name                 = "pe-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Base /16 + 11 bits = /27 (32 IPs for Private Endpoints)
  address_prefixes = [cidrsubnet(var.address_space[0], 11, 137)]
}
