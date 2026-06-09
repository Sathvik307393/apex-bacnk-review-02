variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "South Africa North"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "nexabank-rg"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "aks_subnet_prefix" {
  type    = string
  default = "10.10.0.0/21"
}

variable "appgw_subnet_prefix" {
  type    = string
  default = "10.10.8.0/24"
}

variable "db_subnet_prefix" {
  type    = string
  default = "10.10.9.0/24"
}

variable "pe_subnet_prefix" {
  type    = string
  default = "10.10.10.0/24"
}

variable "func_subnet_prefix" {
  type    = string
  default = "10.10.11.0/24"
}

variable "postgres_admin_user" {
  type    = string
  default = "nexaadmin"
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}
