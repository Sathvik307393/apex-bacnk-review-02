variable "aks_name" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "subnet_id" { type = string }
variable "acr_id" { type = string }
variable "appgw_id" { 
  type = string 
  description = "Application Gateway ID for the AGIC addon"
}
variable "tags" { type = map(string) }
