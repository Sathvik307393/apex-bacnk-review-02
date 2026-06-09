variable "dns_name" {
  type        = string
  description = "The name of the private DNS zone"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the private DNS zone"
}

