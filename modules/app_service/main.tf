resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2" # Adjust as needed
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id
  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
      node_version = "16-lts"
    }
  }
}

# Grant Managed Identity access to Cosmos
data "azurerm_role_definition" "cosmos_reader" {
  name = "Cosmos DB Account Reader Role"
}

resource "azurerm_role_assignment" "cosmos_access" {
  scope                = var.cosmos_endpoint # Cosmos account ID
  role_definition_name = data.azurerm_role_definition.cosmos_reader.name
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}
