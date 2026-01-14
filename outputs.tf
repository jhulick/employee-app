# Outputs
output "app_service_url" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "cosmos_endpoint" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}

output "cosmos_key" {
  value     = azurerm_cosmosdb_account.cosmos.primary_key
  sensitive = true
}
