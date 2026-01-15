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

variable "cosmos_endpoint" {
  type        = string
  description = "The cosmos db endpoint."
}
