output "kyc_function_app_name" {
  value = module.kyc_function.name
}

output "kyc_function_default_hostname" {
  value = module.kyc_function.default_hostname
}

output "kyc_raw_container_name" {
  value = module.storage_account.kyc_documents_container_name
}

output "kyc_processed_container_name" {
  value = module.storage_account.processed_documents_container_name
}
