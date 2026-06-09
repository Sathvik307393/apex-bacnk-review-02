variable "guest_email" {
  type        = string
  description = "The email address of the B2B guest user to invite."
}

variable "storage_account_id" {
  type        = string
  description = "The ID of the storage account to assign the reviewer role to."
}
