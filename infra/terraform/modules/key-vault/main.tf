data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.kv_name
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    # "Purge" is required when Terraform destroys and recreates the vault
    # (e.g. when changing regions) — soft-deleted secrets must be purged first
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  }

  dynamic "access_policy" {
    for_each = var.aks_kv_identity_object_id != "" ? [1] : []
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = var.aks_kv_identity_object_id
      secret_permissions = ["Get"]
    }
  }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "DB-PASSWORD"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "sb_connection_string" {
  name         = "SERVICE-BUS-CONNECTION-STRING"
  value        = var.sb_connection_string
  key_vault_id = azurerm_key_vault.kv.id
}

