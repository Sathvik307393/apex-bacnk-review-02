rg_name            = "nexabank-prod-rg"
location           = "eastus"
vnet_name          = "nexabank-prod-vnet"
vnet_address_space = ["10.1.0.0/16"]
tags = {
  Environment = "prod"
  Project     = "NexaBank"
}
