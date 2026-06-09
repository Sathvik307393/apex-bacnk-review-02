variable "appgw_name" {
  type        = string
  description = "The name of the application gateway"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "location" {
  type        = string
  description = "The location of the application gateway"
}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the application gateway"
}

