terraform {
  backend "azurerm" {
    # Values injected during initialization for dynamic workspaces
    # terraform init -backend-config="resource_group_name=..."
  }
}
