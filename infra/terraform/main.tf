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
  storage_name = "stnexabank${var.tags["Environment"]}"
  location     = var.location
  rg_name      = module.resource_group.name
  tags         = var.tags
}

# NOTE: Entra RBAC guest invite requires 'User.Invite.All' permission on the
# Service Principal used by GitHub Actions. This is a Microsoft Graph API
# privilege that must be explicitly granted by an Azure AD Global Admin.
# Disabled for now to unblock the main infrastructure deployment.
# module "entra_rbac" {
#   source             = "./modules/entra-rbac"
#   guest_email        = "sathvik.vbn@gmail.com"
#   storage_account_id = module.storage_account.id
# }

module "service_bus" {
  source   = "./modules/service-bus"
  sb_name  = "sb-nexabank-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "log_analytics" {
  source   = "./modules/log-analytics"
  law_name = "log-nexabank-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "monitoring" {
  source                     = "./modules/monitoring"
  ai_name                    = "appi-nexabank-${var.tags["Environment"]}"
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
  db_server_name      = "psql-nexabank-${var.tags["Environment"]}"
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
  kv_name                   = "kv-nexabank-${var.tags["Environment"]}"
  location                  = var.location
  rg_name                   = module.resource_group.name
  db_password               = var.db_admin_password
  sb_connection_string      = module.service_bus.primary_connection_string
  tags                      = var.tags
  aks_kv_identity_object_id = module.aks.kv_identity_object_id
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = "crnexabank${var.tags["Environment"]}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

module "aks" {
  source    = "./modules/aks"
  aks_name  = "aks-nexabank-${var.tags["Environment"]}"
  location  = var.location
  rg_name   = module.resource_group.name
  subnet_id = module.network.aks_subnet_id
  acr_id    = module.acr.id
  tags      = var.tags
}

module "application_gateway" {
  source     = "./modules/application-gateway"
  appgw_name = "agw-nexabank-${var.tags["Environment"]}"
  rg_name    = module.resource_group.name
  location   = var.location
  subnet_id  = module.network.appgw_subnet_id
  tags       = var.tags
}

module "nsg" {
  source   = "./modules/nsg"
  nsg_name = "nsg-nexabank-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "route_table" {
  source   = "./modules/route-table"
  rt_name  = "rt-nexabank-${var.tags["Environment"]}"
  location = var.location
  rg_name  = module.resource_group.name
  tags     = var.tags
}

module "pe_keyvault" {
  source             = "./modules/private-endpoints"
  pe_name            = "pe-kv-nexabank-${var.tags["Environment"]}"
  location           = var.location
  rg_name            = module.resource_group.name
  subnet_id          = module.network.pe_subnet_id
  target_resource_id = module.key_vault.id
  subresource_names  = ["vault"]
}

# NOTE: Azure Front Door is NOT supported on Free Trial / Student Azure accounts.
# This module must be enabled after upgrading to a Pay-As-You-Go subscription.
# module "front_door" {
#   source             = "./modules/front-door"
#   frontdoor_name     = "afd-nexabank-${var.tags["Environment"]}"
#   rg_name            = module.resource_group.name
#   custom_domain_name = "sathvikdevops.site"
#   tags               = var.tags
# }
