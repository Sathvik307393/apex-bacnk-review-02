variable "function_app_name" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
}

variable "storage_connection_string" {
  type      = string
  sensitive = true
}

variable "application_insights_connection_string" {
  type      = string
  sensitive = true
}

variable "service_bus_connection_string" {
  type      = string
  sensitive = true
}

variable "service_bus_result_queue_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
