resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix = var.aks_name
  # 1.36.0 is the only KubernetesOfficial (non-LTS) version in northeurope
  kubernetes_version = "1.36"

  default_node_pool {
    name           = "default"
    node_count     = 2
    # Standard_DS2_v2 is not allowed in northeurope for this subscription.
    # Using Standard_EC2ads_v5 as it was explicitly listed in the allowed SKUs error.
    vm_size        = "Standard_EC2ads_v5"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
