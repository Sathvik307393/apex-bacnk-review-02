variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "location" {
  type        = string
  description = "The location of the resource group"
}
variable "vnet_name" {
  type        = string
  description = "The name of the virtual network"
}
variable "vnet_address_space" {
  type        = list(string)
  description = "The address space of the virtual network"
}
variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
}
variable "db_admin_user" {
  type        = string
  description = "The admin username for the Postgres DB"
  default     = "psqladmin"
}
variable "db_admin_password" {
  type        = string
  description = "The admin password for the Postgres DB"
  sensitive   = true
  default     = "Crocodile@1234"
}
