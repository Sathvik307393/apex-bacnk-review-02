variable "vnet_name" {
  type        = string
  description = "The name of the virtual network"
}
variable "location" {
  type        = string
  description = "The location of the virtual network"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "address_space" {
  type        = list(string)
  description = "The address space of the virtual network"
}
variable "tags" {
  type    = map(string)
  default = {}
}

