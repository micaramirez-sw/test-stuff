variable "environment" {
  description = "Environment of resources."
  type        = string
}

variable "location" {
  description = "Location of resource."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the function storage account."
  type        = string
}

variable "storage_container_name" {
  description = "Name of the storage container."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group of the functions."
  type        = string
}

variable "service_plan_id" {
  description = "Id of the service plan function."
  type        = string
}

variable "storage_account_primary_access_key" {
  description = "Storage account primary access key"
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name."
  type        = string
}

variable "threshold_days" {
  description = "Limit of days that can a VM be alive"
  type        = number
}

variable "threshold_builds" {
  description = "Limit of buildbots that can be associated to a builder"
  type        = number
}
