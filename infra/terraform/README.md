# Nexa Bank (Apex Bank) - Enterprise Terraform Infrastructure

This repository contains the Enterprise-grade Infrastructure as Code (IaC) for Nexa Bank, managed entirely via **Terraform** and deployed via **GitHub Actions**.

## Directory Structure
The Terraform code strictly follows the enterprise module pattern:
- `infra/terraform/modules/`: Contains atomic, reusable modules (`resource-group`, `network`, `aks`, `postgresql-flexible-server`, etc.).
- `infra/terraform/environments/`: Contains environment-specific configurations (`dev.tfvars`, `prod.tfvars`).
- `infra/terraform/`: The root module connecting all resources.

## Setup Instructions
1. Navigate to the Terraform root:
   ```bash
   cd infra/terraform
   ```
2. Initialize Terraform (Requires Azure login):
   ```bash
   terraform init
   ```
3. Plan the infrastructure:
   ```bash
   terraform plan -var-file="environments/dev.tfvars"
   ```

## Required GitHub Secrets
To use the automated GitHub Actions deployment, you must configure the following secrets in your repository:
- `AZURE_CREDENTIALS` (Service Principal JSON)
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `DB_PASSWORD` (Injected securely into KeyVault)
- `JWT_SECRET` (Injected securely into KeyVault)

## Terraform Drift & Troubleshooting
- **Drift Detection:** The GitHub Actions pipeline runs `terraform plan` on every PR to detect drift automatically.
- **Taint vs Replace:** `terraform taint` is deprecated. If a resource becomes corrupted (like a failed PostgreSQL deployment), use the modern equivalent:
  ```bash
  terraform apply -replace="module.postgresql-flexible-server.azurerm_postgresql_flexible_server.pg"
  ```
- **PostgreSQL Connectivity Issues:** If the AKS microservices cannot connect to the database, verify that the `private-dns` zone is properly linked to the AKS `vnet` and that the `DB_PASSWORD` secret has successfully synchronized from Key Vault into the Kubernetes secret store.

## State Management
State is managed securely via Azure Blob Storage (`backend.tf`) using lease locking to prevent concurrent state corruption.
