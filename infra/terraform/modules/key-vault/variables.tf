variable "kv_name" {
  type = string
}
variable "location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "sb_connection_string" {
  type      = string
  sensitive = true
}
variable "tags" {
  type = map(string)
}
variable "aks_kv_identity_object_id" {
  type        = string
  description = "The Object ID of the AKS Key Vault Secrets Provider managed identity"
  default     = ""
}
