resource "azurerm_service_plan" "plan" {
  name                = "${var.function_app_name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_function_app" "func" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "20"
    }
    minimum_tls_version = "1.2"
  }

  # Enable static website hosting (for React build)
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"  # Deploy via zip
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.func.default_hostname
}
