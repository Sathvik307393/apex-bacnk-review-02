resource "azurerm_service_plan" "functions" {
  name                = var.service_plan_name
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1"
  tags                = var.tags
}

resource "azurerm_windows_function_app" "kyc_processor" {
  name                        = var.function_app_name
  resource_group_name         = var.rg_name
  location                    = var.location
  service_plan_id             = azurerm_service_plan.functions.id
  storage_account_name        = var.storage_account_name
  storage_account_access_key  = var.storage_account_access_key
  functions_extension_version = "~4"
  https_only                  = true
  tags                        = var.tags

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME              = "node"
    KycStorage                            = var.storage_connection_string
    RAW_CONTAINER_NAME                    = "kyc-documents"
    PROCESSED_CONTAINER_NAME              = "processed-and-validated-container"
    ServiceBusConnection                  = var.service_bus_connection_string
    SERVICE_BUS_RESULT_QUEUE              = var.service_bus_result_queue_name
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
  }

  site_config {
    application_stack {
      node_version = "~20"
    }
  }
}
