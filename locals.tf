locals {
  remote_tf_state_resource_group_name        = var.remote_tf_state_resource_group_name
  remote_tf_state_storage_account_name       = var.remote_tf_state_storage_account_name
  remote_tf_state_container_name             = var.remote_tf_state_container_name
  remote_tf_state_blob_key                   = var.remote_tf_state_blob_key
  remote_tf_state_storage_account_access_key = var.remote_tf_state_storage_account_access_key

  library_path = "${path.root}/lib"
}