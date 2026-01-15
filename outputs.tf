# Outputs
output "app_service_url" {
  value = module.app_service.default_host_name
}

output "cosmos_endpoint" {
  value = module.cosmos_db.endpoint
}

output "cosmos_key" {
  value     = module.cosmos_db.primary_key
  sensitive = true
}
