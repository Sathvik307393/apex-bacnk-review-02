variable "ai_name" {
  type        = string
  description = "The name of the application insights"
}
variable "location" {
  type        = string
  description = "The location of the application insights"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the log analytics workspace"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the application insights"
}

