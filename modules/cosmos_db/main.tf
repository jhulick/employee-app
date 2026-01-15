resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_db_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocument"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = var.location
    failover_priority = 0
  }
  enable_multiple_write_locations = false
  public_network_access_enabled   = false # For private endpoint
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "employees"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400 # RU/s
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "employees"
  resource_group_name = var.resource_group_name
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

resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "cosmos-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = "cosmos-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }
}


# Assign Managed Identity to Cosmos DB Role
resource "azurerm_role_assignment" "mi_cosmos" {
  scope                = azurerm_cosmosdb_account.cosmos.id
  role_definition_name = "Cosmos DB Built-in Data Contributor"
  principal_id         = var.principal_id
}

# Private DNS Zone for Cosmos DB
resource "azurerm_private_dns_zone" "cosmos_dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_link" {
  name                  = "cosmos-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_dns.name
  virtual_network_id    = var.vnet_id
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
    for emp in jsondecode(file("${path.module}/modules/cosmos_db/employees.json")) : emp.id => {
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
