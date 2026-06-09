resource "azurerm_application_insights" "appinsights" {
  name                = var.ai_name
  location            = var.location
  resource_group_name = var.rg_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id
  tags                = var.tags
}

