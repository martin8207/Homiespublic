terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
}
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "azurerm_resource_group" "homiesrg" {
  name     = "homiesrg"
  location = "West Europe"

}

resource "azurerm_service_plan" "asp" {
  name                = "homies_asp"
  resource_group_name = azurerm_resource_group.homiesrg.name
  location            = azurerm_resource_group.homiesrg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "linux-app"
  resource_group_name = azurerm_resource_group.homiesrg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id


  site_config {
    application_stack {
      node_version = "18-lts"

    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "aassc" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = "https://github.com/nakov/ContactBook"
  branch                 = "master"
  use_manual_integration = true
}