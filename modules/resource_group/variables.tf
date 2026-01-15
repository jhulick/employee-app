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
