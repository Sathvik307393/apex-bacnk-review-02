module "resource_group" {
  source   = "./modules/resource-group"
  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source        = "./modules/network"
  vnet_name     = var.vnet_name
  location      = var.location
  rg_name       = module.resource_group.name
  address_space = var.vnet_address_space
  tags          = var.tags
}

module "storage_account" {
  source       = "./modules/storage-account"
  storage_name = "nexabankstorage${var.tags["Environment"]}"
  location     = var.location
  rg_name      = module.resource_group.name
  tags         = var.tags
}

module "entra_rbac" {
  source             = "./modules/entra-rbac"
  guest_email        = "sathvik.vbn@gmail.com" # Example email
  storage_account_id = module.storage_account.id
}

module "service_bus" {
  source   = "./modules/service-bus"
  sb_name  = "nexabanksb${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "log_analytics" {
  source   = "./modules/log-analytics"
  law_name = "nexa-law-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "monitoring" {
  source                     = "./modules/monitoring"
  ai_name                    = "nexa-ai-${var.tags["Environment"]}"
  location                   = var.location
  rg_name                    = module.resource_group.name
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags
}

module "private_dns" {
  source   = "./modules/private-dns"
  dns_name = "privatelink.postgres.database.azure.com"
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "postgresql" {
  source              = "./modules/postgresql-flexible-server"
  db_server_name      = "nexa-db-${var.tags["Environment"]}"
  rg_name             = module.resource_group.name
  location            = var.location
  subnet_id           = module.network.db_subnet_id
  private_dns_zone_id = module.private_dns.id
  admin_user          = var.db_admin_user
  admin_password      = var.db_admin_password
  tags                = var.tags
}

module "key_vault" {
  source               = "./modules/key-vault"
  kv_name              = "nexa-kv-${var.tags["Environment"]}"
  location             = var.location
  rg_name              = module.resource_group.name
  db_password          = var.db_admin_password
  sb_connection_string = module.service_bus.primary_connection_string
  tags                 = var.tags
}

module "aks" {
  source    = "./modules/aks"
  aks_name  = "nexa-aks-${var.tags["Environment"]}"
  location  = var.location
  rg_name   = module.resource_group.name
  subnet_id = module.network.aks_subnet_id
  tags      = var.tags
}

module "application_gateway" {
  source     = "./modules/application-gateway"
  appgw_name = "nexa-appgw-${var.tags["Environment"]}"
  rg_name    = module.resource_group.name
  location   = var.location
  subnet_id  = module.network.appgw_subnet_id
  tags       = var.tags
}

module "nsg" {
  source   = "./modules/nsg"
  nsg_name = "nexa-nsg-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "route_table" {
  source   = "./modules/route-table"
  rt_name  = "nexa-rt-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "pe_keyvault" {
  source             = "./modules/private-endpoints"
  pe_name            = "nexa-pe-kv-${var.tags["Environment"]}"
  location           = var.location
  rg_name            = module.resource_group.name
  subnet_id          = module.network.pe_subnet_id
  target_resource_id = module.key_vault.id
  subresource_names  = ["vault"]
}

module "front_door" {
  source         = "./modules/front-door"
  frontdoor_name = "apexbank-fd-${var.tags["Environment"]}"
  rg_name        = module.resource_group.name
  # location           = var.location
  custom_domain_name = "sathvikdevops.site"
  tags               = var.tags
}
