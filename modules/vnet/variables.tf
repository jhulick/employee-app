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

variable "vnet_name" {
  type        = string
  description = "The app virtual network name."
  default     = "employee-vnet"
}

variable "address_space" {
  type        = list(any)
  description = "The virtual network address space."
  default     = ["10.0.0.0/16"]
}
