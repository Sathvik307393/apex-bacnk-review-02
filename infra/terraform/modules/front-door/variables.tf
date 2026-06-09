variable "frontdoor_name" {
  type        = string
  description = "The name of the front door"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the front door"
}
variable "custom_domain_name" {
  type        = string
  description = "The custom domain to map to Front Door"
}
