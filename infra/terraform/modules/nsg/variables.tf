variable "nsg_name" {
  type        = string
  description = "The name of the network security group"
}
variable "location" {
  type        = string
  description = "The location of the network security group"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the network security group"
}

