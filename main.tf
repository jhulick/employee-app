terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.15"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet for App Service
resource "azurerm_subnet" "app_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "appservice-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Private Endpoint
resource "azurerm_subnet" "pe_subnet" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Cosmos DB Account (SQL API)
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_db_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  enable_automatic_failover     = false
  public_network_access_enabled = false # For private access
}

# Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "employees-db"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400 # RU/s
}

# Cosmos DB Container
resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "employees"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/department"
  throughput          = 400

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/_etag/?"
    }
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Seed the data using azapi (runs only on apply, idempotent via upsert)
# ──────────────────────────────────────────────────────────────────────────────
resource "azapi_resource_action" "seed_employees" {
  type        = "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15"
  resource_id = azurerm_cosmosdb_sql_container.container.id
  action      = "items"
  method      = "POST"

  # We use azapi_resource_action in a null_resource-like pattern with triggers
  # This block runs only when data changes or container is recreated

  depends_on = [
    azurerm_cosmosdb_sql_container.container
  ]

  body = jsonencode({
    for emp in jsondecode(file("${path.module}/employees.json")) : emp.id => {
      id         = tostring(emp.id)
      image      = emp.image
      name       = emp.name
      department = emp.department
      email      = emp.email
      phone      = emp.phone
    }
  })

  # Use a trigger to make it run only when data or container changes
  lifecycle {
    replace_triggered_by = [
      azurerm_cosmosdb_sql_container.container
    ]
  }
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# App Service (Node.js Backend)
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Assign Managed Identity to Cosmos DB Role
resource "azurerm_role_assignment" "mi_cosmos" {
  scope                = azurerm_cosmosdb_account.cosmos.id
  role_definition_name = "Cosmos DB Built-in Data Contributor"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

# Private Endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "cosmos-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "cosmos-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    subresource_names              = ["Sql"]
  }
}

# Private DNS Zone for Cosmos DB
resource "azurerm_private_dns_zone" "cosmos_dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_link" {
  name                  = "cosmos-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
