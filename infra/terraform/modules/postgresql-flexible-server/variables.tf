variable "db_server_name" {
  type        = string
  description = "The name of the database server"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "location" {
  type        = string
  description = "The location of the database server"
}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet"
}
variable "private_dns_zone_id" {
  type        = string
  description = "The ID of the private DNS zone"
}
variable "admin_user" {
  type        = string
  description = "The admin username for the database server"
}
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "tags" {
  type    = map(string)
  default = {}
}

