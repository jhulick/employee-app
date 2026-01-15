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
  subscription_id = "a732c989-d99b-42c2-9f7c-393ef01a05f2"
}

provider "azapi" {
  subscription_id = "a732c989-d99b-42c2-9f7c-393ef01a05f2"
}

# Custom Modules

# Resource Group
module "resource_group" {
  source              = "./modules/resource_group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  vnet_name           = var.vnet_name
  resource_group_name = module.resource_group.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

module "cosmos_db" {
  source                 = "./modules/cosmos_db"
  cosmos_db_account_name = var.cosmos_db_account_name
  resource_group_name    = module.resource_group.name
  location               = var.location
  vnet_id                = module.vnet.vnet_id
  subnet_id              = module.vnet.private_endpoint_subnet_id
  principal_id           = module.app_service.principal_id
}

module "app_service" {
  source                = "./modules/app_service"
  app_service_plan_name = var.app_service_plan_name
  app_service_name      = var.app_service_name
  resource_group_name   = module.resource_group.name
  location              = var.location
  cosmos_endpoint       = module.cosmos_db.endpoint
  cosmos_key            = module.cosmos_db.primary_key # Use Managed Identity instead for prod
}

# ──────────────────────────────────────────────────────────────────────────────
# Build React + Deploy using null_resource
# ──────────────────────────────────────────────────────────────────────────────
resource "null_resource" "build_and_deploy_react" {
  triggers = {
    # Re-run build/deploy when React source files change
    react_source_hash = sha256(join("", [for f in fileset(var.react_source_path, "**/*") : filesha256("${var.react_source_path}/${f}")]))
  }

  provisioner "local-exec" {
    # Build the React app locally
    command = <<EOT
      cd ${var.react_source_path}
      npm ci
      npm run build
    EOT
  }

  provisioner "local-exec" {
    # Zip the build folder
    command = <<EOT
      cd ${var.react_source_path}
      if [ -f build.zip ]; then rm build.zip; fi
      zip -r build.zip build
    EOT
  }

  provisioner "local-exec" {
    # Deploy to Azure App Service using Azure CLI
    command = <<EOT
      az webapp deploy \
        --resource-group ${module.resource_group.name} \
        --name ${var.app_service_name} \
        --src-path ${var.react_source_path}/build.zip \
        --type zip \
        --clean true
    EOT
  }

  depends_on = [
    module.app_service
  ]
}
