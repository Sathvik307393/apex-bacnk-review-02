terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.71.0"
    }
  }
}

# 1. Invite the external B2B user
resource "azuread_invitation" "guest" {
  user_email_address = var.guest_email
  redirect_url       = "https://portal.azure.com"
}

# 2. Look up the invited user's Object ID in Azure AD
data "azuread_user" "guest_user" {
  object_id = azuread_invitation.guest.user_id
}

# 3. Assign the "Storage Blob Data Reader" role to the user for the Storage Account
resource "azurerm_role_assignment" "blob_reviewer" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azuread_user.guest_user.object_id
}
