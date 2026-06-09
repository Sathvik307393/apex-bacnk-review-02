variable "storage_name" {
  type        = string
  description = "The name of the storage account"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "location" {
  type        = string
  description = "The location of the storage account"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the storage account"
}

