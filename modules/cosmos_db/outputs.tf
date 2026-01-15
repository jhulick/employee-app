output "endpoint" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}

output "primary_key" {
  value     = azurerm_cosmosdb_account.cosmos.primary_key
  sensitive = true
}
