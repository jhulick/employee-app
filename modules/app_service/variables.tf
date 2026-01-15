variable "app_service_plan_name" {
  type        = string
  description = "The app service plan name."
}

variable "app_service_name" {
  type        = string
  description = "The app service name."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group for the app."
}

variable "location" {
  type        = string
  description = "The location of the app deployment."
}

variable "cosmos_endpoint" {
  type        = string
  description = "The cosmos db endpoint."
}
