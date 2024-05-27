variable "location" {
  description = "Default location to deploy the resources"
  type        = string
  default = "EastUS"
}

variable "root_id" {
  description = "If specified, will set a custom Name (ID) value for the Enterprise-scale root Management Group, and append this to the ID for all core Enterprise-scale Management Groups"
  type        = string
  default     = "es"
}

variable "root_name" {
  description = "If specified, will set a custom Display Name value for the Enterprise-scale root Management Group"
  type        = string
  default     = "Enterprise-Scale"
}


variable "deploy_demo_landing_zones" {
  description = "Deploy landing zones demo corp, online and sap"
  type        = bool
  default = true
}

variable "custom_landing_zones" {
  type = map(
    object({
      display_name               = string
      parent_management_group_id = string
      subscription_ids           = list(string)
      archetype_config = object({
        archetype_id   = string
        parameters     = map(any)
        access_control = map(list(string))
      })
    })
  )
  default = {}
}

variable "remote_tf_state_resource_group_name" {
  description = "The resource group name where is located the storage account for the remote terraform state"
  type        = string
}

variable "remote_tf_state_storage_account_name" {
  description = "The storage account name where is located the storage account for the remote terraform state"
  type        = string
}

variable "remote_tf_state_container_name" {
  description = "The container name where is located the blob for the remote terraform state"
  type        = string
}

variable "remote_tf_state_blob_key" {
  description = "The blob key where is located the remote terraform state"
  type        = string
}

variable "remote_tf_state_storage_account_access_key" {
  description = "The access key to access the storage account where is located the remote terraform state"
  type        = string
  sensitive   = true
}