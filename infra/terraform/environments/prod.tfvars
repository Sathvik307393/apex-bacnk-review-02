rg_name            = "rg-nexabank-prod"
location           = "swedencentral"
vnet_name          = "vnet-nexabank-prod"
vnet_address_space = ["172.17.0.0/16"]
tags = {
  Environment = "prod"
  Project     = "NexaBank"
}
