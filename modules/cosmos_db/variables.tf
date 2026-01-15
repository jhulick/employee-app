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

variable "subnet_id" {
  type        = string
  description = "The subnet id to deploy to."
}

