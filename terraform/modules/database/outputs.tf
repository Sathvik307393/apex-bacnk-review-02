output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.postgres.name
}
output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}
