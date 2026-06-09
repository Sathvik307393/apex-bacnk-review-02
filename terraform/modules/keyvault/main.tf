data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "nexabankkv${random_string.suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  public_network_access_enabled = false
}

resource "azurerm_role_assignment" "deployer_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "POSTGRES-PASSWORD"
  value        = var.postgres_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  
  depends_on = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "JWT-SECRET"
  value        = random_password.jwt.result
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "random_password" "jwt" {
  length  = 32
  special = true
}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_vnet_link" {
  name                  = "kv-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "nexabank-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "kv-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
