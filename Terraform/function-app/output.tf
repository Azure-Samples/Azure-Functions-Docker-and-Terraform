// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This configures Terraform to display the module's output during the `terraform plan` and `terraform apply` steps.
output "azure_function_id" {
    description = "The URLs of the app services created."
    value       = azurerm_function_app.fnapp.*.id
}
output "azure_function_url" {
    description = "The resource ids of the app services created."
    value       = azurerm_function_app.fnapp.*.default_hostname
}
output "app_service_type" {
    description = "The type of app service created."
    value       = azurerm_function_app.fnapp.*.kind
}