rg_name            = "nexabank-dev-rg"
location           = "eastus"
vnet_name          = "nexabank-dev-vnet"
vnet_address_space = ["10.0.0.0/16"]
tags = {
  Environment = "dev"
  Project     = "NexaBank"
}
