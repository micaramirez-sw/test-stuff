data "azurerm_client_config" "core" {}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "5.1.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = var.location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
  library_path   = local.library_path

  deploy_demo_landing_zones = var.deploy_demo_landing_zones
#   custom_landing_zones      = var.custom_landing_zones
}