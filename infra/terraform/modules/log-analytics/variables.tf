variable "law_name" {
  type        = string
  description = "The name of the log analytics workspace"
}
variable "location" {
  type        = string
  description = "The location of the log analytics workspace"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the log analytics workspace"
}

