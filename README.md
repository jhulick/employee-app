# How to Use This Terraform Code

1. Save as `main.tf`.
2. Create `variables.tf` with the variables defined.
3. Run `terraform init`, `terraform plan`, `terraform apply`.
4. The deployment automatically builds and the deploys the web app. One may choose to manually deploy after deployment if preferred:
- Build and deploy your React SPA and Node.js backend to the App Service (use `az webapp deploy` or CI/CD).
- In Node.js, use Managed Identity to connect to Cosmos: `const credential = new DefaultAzureCredential(); const client = new CosmosClient({ endpoint, credential });`.
- Seed data in Cosmos (e.g., employees collection with name/department fields).
- Access the app at `https://<app_service_name>.azurewebsites.net`.

This uses private endpoint for Cosmos, Managed Identity for auth, and a simple VNet setup. For production, add WAF, monitoring, and scale. Let me know if you need the React/Node code or refinements!

![Employees App](./employees.png)
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.15 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 1.15 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Security Controls (NIST 800-53 Rev 5)

| NIST Control ID | Control Title | Implementation in Solution |
|-----------------|---------------|----------------------------|
| AC-4 | Information Flow Enforcement | Private Endpoint for Cosmos DB restricts traffic to VNet; App Service VNet integration ensures secure flow. |
| AC-17 | Remote Access | Managed Identity eliminates credentials; no direct remote access to DB. |
| SC-8 | Transmission Confidentiality and Integrity | HTTPS enforced in App Service; Cosmos DB private endpoint uses Azure backbone. |
| SC-28 | Protection of Information at Rest | Cosmos DB encryption at rest (default); optional CMK integration. |
| AU-12 | Audit Record Generation | Diagnostic settings log HTTP requests and metrics to Log Analytics. |
| SI-4 | System Monitoring | App Service diagnostics and Cosmos DB metrics enable anomaly detection. |

## Resources

| Name | Type |
|------|------|
| [azapi_resource_action.seed_employees](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [azurerm_cosmosdb_account.cosmos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_sql_database.db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_linux_web_app.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_private_dns_zone.cosmos_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.cosmos_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.cosmos_pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.mi_cosmos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.app_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.pe_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [null_resource.build_and_deploy_react](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_name"></a> [app\_service\_name](#input\_app\_service\_name) | The app service name. | `string` | `"employee-app-service"` | no |
| <a name="input_app_service_plan_name"></a> [app\_service\_plan\_name](#input\_app\_service\_plan\_name) | The app service plan name. | `string` | `"employee-app-plan"` | no |
| <a name="input_cosmos_db_account_name"></a> [cosmos\_db\_account\_name](#input\_cosmos\_db\_account\_name) | The cosmos db account name. | `string` | `"employee-cosmosdb"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of the app deployment. | `string` | `"westus2"` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | The private endpoint name. | `string` | `"private-endpoint-subnet"` | no |
| <a name="input_react_source_path"></a> [react\_source\_path](#input\_react\_source\_path) | The path to the react app source. | `string` | `"./emp-app"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group for the app. | `string` | `"employee-app-rg"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The app subnet name. | `string` | `"employee-subnet"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The app virtual network name. | `string` | `"employee-vnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_url"></a> [app\_service\_url](#output\_app\_service\_url) | Outputs |
| <a name="output_cosmos_endpoint"></a> [cosmos\_endpoint](#output\_cosmos\_endpoint) | n/a |
| <a name="output_cosmos_key"></a> [cosmos\_key](#output\_cosmos\_key) | n/a |
<!-- END_TF_DOCS -->