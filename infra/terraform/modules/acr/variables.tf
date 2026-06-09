variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry"
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}
variable "location" {
  type        = string
  description = "Location for the ACR"
}
variable "sku" {
  type        = string
  description = "The SKU of the container registry"
  default     = "Premium"
}
variable "admin_enabled" {
  type        = bool
  description = "Enable admin user on the ACR"
  default     = false
}
variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
