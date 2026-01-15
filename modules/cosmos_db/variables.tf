variable "resource_group_name" {
  type        = string
  description = "The resource group for the app."
}

variable "location" {
  type        = string
  description = "The location of the app deployment."
}

variable "cosmos_db_account_name" {
  type        = string
  description = "The cosmos db account name."
}

variable "subnet_id" {
  type        = string
  description = "The subnet id to deploy to."
}

variable "vnet_id" {
  type        = string
  description = "The vnet id to deploy to."
}

variable "principal_id" {
  type        = string
  description = "The principal id."
}
