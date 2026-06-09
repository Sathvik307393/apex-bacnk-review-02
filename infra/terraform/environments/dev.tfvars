rg_name            = "rg-nexabank-dev"
location           = "northeurope"
vnet_name          = "vnet-nexabank-dev"
vnet_address_space = ["172.16.0.0/16"]
tags = {
  Environment = "dev"
  Project     = "NexaBank"
}
