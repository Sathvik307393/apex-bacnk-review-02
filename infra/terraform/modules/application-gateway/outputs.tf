output "id" { value = azurerm_application_gateway.appgw.id }
output "public_ip" { value = azurerm_public_ip.appgw_pip.ip_address }

