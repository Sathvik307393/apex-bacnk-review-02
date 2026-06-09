variable "kv_name" {
  type        = string
  description = "The name of the key vault"
}
variable "location" {
  type        = string
  description = "The location of the key vault"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
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
  type        = map(string)
  default     = {}
  description = "Tags to apply to the key vault"
}

