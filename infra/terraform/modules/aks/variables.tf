variable "aks_name" {
  type        = string
  description = "The name of the AKS cluster"
}
variable "location" {
  type        = string
  description = "The location of the AKS cluster"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the AKS cluster"
}

