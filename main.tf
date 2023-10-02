module "function_delete_old_buildbots" {
  source                             = "./modules-terraform/function"
  path                               = "${path.module}/../delete-old-buildbots-function"
  name                               = "DeleteOldBuildbots"
  function_name                      = "ucb-mgue-delete-old-buildbots-func001"
  environment                        = var.environment
  location                           = var.location
  storage_account_name               = var.storage_account_name
  storage_container_name             = var.storage_container_name
  resource_group_name                = var.resource_group_name
  service_plan_id                    = var.service_plan_id
  storage_account_primary_access_key = var.storage_account_primary_access_key
  key_vault_name                     = var.key_vault_name
  app_settings = {
    "THRESHOLD_DAYS" = var.threshold_days
  }
}

module "function_check_buildbots_on_builders" {
  source                             = "./modules-terraform/"
  path                               = "${path.module}/../buildbots-check-on-builders-function"
  name                               = "CheckBuildbotsOnBuilders"
  function_name                      = "ucb-mgue-check-on-builders-func001"
  environment                        = var.environment
  location                           = var.location
  storage_account_name               = var.storage_account_name
  storage_container_name             = var.storage_container_name
  resource_group_name                = var.resource_group_name
  service_plan_id                    = var.service_plan_id
  storage_account_primary_access_key = var.storage_account_primary_access_key
  key_vault_name                     = var.key_vault_name
  app_settings = {
    "THRESHOLD_BUILDS"    = var.threshold_builds
  }
}
