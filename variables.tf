variable "resource_group_name" {
  type        = string
  description = "The resource group for the app."
  default     = "employee-app-rg"
}

variable "location" {
  type        = string
  description = "The location of the app deployment."
  default     = "westus2"
}

variable "cosmos_db_account_name" {
  type        = string
  description = "The cosmos db account name."
  default     = "employee-cosmosdb"
}

variable "app_service_plan_name" {
  type        = string
  description = "The app service plan name."
  default     = "employee-app-plan"
}

variable "app_service_name" {
  type        = string
  description = "The app service name."
  default     = "employee-app-service"
}

variable "vnet_name" {
  type        = string
  description = "The app virtual network name."
  default     = "employee-vnet"
}

variable "subnet_name" {
  type        = string
  description = "The app subnet name."
  default     = "employee-subnet"
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "The private endpoint name."
  default     = "private-endpoint-subnet"
}

variable "react_source_path" {
  type        = string
  description = "The path to the react app source."
  default     = "./emp-app"
}
