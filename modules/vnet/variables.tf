variable "resource_group_name" {
  type        = string
  description = "The resource group for the app."
}

variable "location" {
  type        = string
  description = "The location of the app deployment."
}

variable "vnet_name" {
  type        = string
  description = "The app virtual network name."
}

variable "address_space" {
  type        = list(any)
  description = "The virtual network address space."
}
