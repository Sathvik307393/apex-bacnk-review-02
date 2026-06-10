resource "azurerm_storage_account" "st" {
  name                     = var.storage_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_storage_container" "kyc_documents" {
  name                  = "kyc-documents"
  storage_account_id    = azurerm_storage_account.st.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed_documents" {
  name                  = "processed-and-validated-container"
  storage_account_id    = azurerm_storage_account.st.id
  container_access_type = "private"
}

