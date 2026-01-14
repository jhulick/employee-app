variable "resource_group_name" {
  type    = string
  default = "employee-app-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "cosmos_db_account_name" {
  type    = string
  default = "employee-cosmosdb"
}

variable "app_service_plan_name" {
  type    = string
  default = "employee-app-plan"
}

variable "app_service_name" {
  type    = string
  default = "employee-app-service"
}

variable "vnet_name" {
  type    = string
  default = "employee-vnet"
}

variable "subnet_name" {
  type    = string
  default = "employee-subnet"
}

variable "private_endpoint_subnet_name" {
  type    = string
  default = "private-endpoint-subnet"
}
