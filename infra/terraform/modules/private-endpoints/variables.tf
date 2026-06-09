variable "pe_name" {
  type        = string
  description = "The name of the private endpoint"
}
variable "location" {
  type        = string
  description = "The location of the private endpoint"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet"
}
variable "target_resource_id" {
  type        = string
  description = "The ID of the target resource"
}
variable "subresource_names" {
  type        = list(string)
  description = "The names of the subresources"
}

