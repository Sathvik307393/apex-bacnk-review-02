variable "rt_name" {
  type        = string
  description = "The name of the route table"
}
variable "location" {
  type        = string
  description = "The location of the route table"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "tags" {
  type        = map(string)
  description = "Tags to apply to the route table"
}
