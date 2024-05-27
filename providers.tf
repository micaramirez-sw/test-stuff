# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-mica"
    storage_account_name = "storageaccountmica"
    container_name       = "terraform"
    key                  = "prod.terraform.tfstate" # asd
    access_key           = ""
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
