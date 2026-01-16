variable "resource_group_name" {
  type        = string
  description = "The resource group for the app."
}

variable "location" {
  type        = string
  description = "The location of the app deployment."
}

variable "function_app_name" {
  type        = string
  description = "The react function app name."
  default     = "employee-react"
}
