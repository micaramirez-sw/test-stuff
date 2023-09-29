data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = var.path
  output_path = "${path.module}/${var.name}.zip"
}

resource "azurerm_storage_blob" "storage_blob_function" {
  name                   = "functions-${substr(data.archive_file.file_function_app.output_md5, 0, 6)}.zip"
  storage_account_name   = var.storage_account_name
  storage_container_name = var.storage_container_name
  type                   = "Block"
  content_md5            = data.archive_file.file_function_app.output_md5
  source                 = "${path.module}/${var.name}.zip"
}

locals {
  kv_ref_template = "@Microsoft.KeyVault(VaultName=%s;SecretName=%s)"
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = azurerm_storage_blob.storage_blob_function.url
    "WEBSITE_TIME_ZONE "       = "Central Standard Time"
    "AZURE_TENANT_ID"          = format(local.kv_ref_template, var.key_vault_name, "AZURE-TENANT-ID")
    "AZURE_STG_CLIENT_ID"      = format(local.kv_ref_template, var.key_vault_name, "AZURE-STG-CLIENT-ID")
    "AZURE_STG_CLIENT_SECRET"  = format(local.kv_ref_template, var.key_vault_name, "AZURE-STG-CLIENT-SECRET")
    "AZURE_STG_OBJECT_ID"      = format(local.kv_ref_template, var.key_vault_name, "AZURE-STG-OBJECT-ID")
    "AZURE_TEST_CLIENT_ID"     = format(local.kv_ref_template, var.key_vault_name, "AZURE-TEST-CLIENT-ID")
    "AZURE_TEST_CLIENT_SECRET" = format(local.kv_ref_template, var.key_vault_name, "AZURE-TEST-CLIENT-SECRET")
    "AZURE_TEST_OBJECT_ID"     = format(local.kv_ref_template, var.key_vault_name, "AZURE-TEST-OBJECT-ID")
    "SLACK_WEBHOOK_URL"        = format(local.kv_ref_template, var.key_vault_name, "SLACK-WEBHOOK-URL")
  }
}

resource "azurerm_windows_function_app" "function_app" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  builtin_logging_enabled    = false
  service_plan_id            = var.service_plan_id
  storage_account_access_key = var.storage_account_primary_access_key
  storage_account_name       = var.storage_account_name

  site_config {
    application_stack {
      powershell_core_version = "7.2"
    }
    http2_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(local.app_settings, var.app_settings)
}
