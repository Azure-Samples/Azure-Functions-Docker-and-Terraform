// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  fn_names                       = keys(var.fn_app_config)
  fn_configs                     = values(var.fn_app_config)

  app_linux_fx_versions = [
    for config in values(var.fn_app_config) :
    config.image == null ? "" : format("DOCKER|%s/%s", var.docker_registry_server_url, config.image)
  ]

  app_deployment_config = [
    for config in values(var.fn_app_config) :
    config.image == null ? 
      config.zip == null ?
        tomap({}) :
        tomap({HASH=config.hash, WEBSITE_RUN_FROM_PACKAGE=config.zip}) :
      tomap({DOCKER_CUSTOM_IMAGE_NAME="${var.docker_registry_server_url}/${config.image}"})
  ]

  static_app_settings = {
    FUNCTIONS_EXTENSION_VERSION         = var.runtime_version
    FUNCTIONS_WORKER_RUNTIME            = var.worker_runtime
    DOCKER_REGISTRY_SERVER_URL          = format("https://%s", var.docker_registry_server_url)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_USERNAME     = var.docker_registry_server_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.docker_registry_server_password
    APPINSIGHTS_INSTRUMENTATIONKEY      = var.app_insights_instrumentation_key
  }

  fn_app_settings = merge(tomap(local.static_app_settings), var.fn_app_settings)
}

data "azurerm_resource_group" "fnapp" {
  name = var.resource_group_name
}

data "azurerm_app_service_plan" "fnapp" {
  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.fnapp.name
}

resource "azurerm_storage_account" "fnapp" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.fnapp.name
  location                 = data.azurerm_resource_group.fnapp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "fnapp" {
  name                      = format("%s-%s", var.fn_name_prefix, lower(local.fn_names[count.index]))
  location                  = data.azurerm_resource_group.fnapp.location
  resource_group_name       = data.azurerm_resource_group.fnapp.name
  app_service_plan_id       = data.azurerm_app_service_plan.fnapp.id
  storage_connection_string = azurerm_storage_account.fnapp.primary_connection_string
  tags                      = var.resource_tags
  version                   = var.runtime_version
  count                     = length(local.fn_names)

  app_settings = merge(local.static_app_settings, local.app_deployment_config[count.index]) 

  site_config {
    linux_fx_version     = local.app_linux_fx_versions[count.index]
    always_on            = var.site_config_always_on
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      site_config[0].linux_fx_version
    ]
  }

}