#!/usr/bin/env bash
# ============================================================
# create-k8s-secret.sh
# Fetches secrets from Azure Key Vault and creates the
# Kubernetes secret in the nexabank namespace.
# Run this once after AKS is provisioned.
#
# Usage:
#   chmod +x azure/create-k8s-secret.sh
#   ./azure/create-k8s-secret.sh
# ============================================================
set -euo pipefail

KV_NAME="${KV_NAME:-nexabank-kv}"
NAMESPACE="${NAMESPACE:-nexabank}"
SECRET_NAME="nexa-secrets"

echo "🔑 Fetching secrets from Key Vault: $KV_NAME"

DB_PASSWORD=$(az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "db-password" \
  --query value -o tsv)

JWT_SECRET=$(az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "jwt-secret" \
  --query value -o tsv)

AZURE_STORAGE_CONNECTION_STRING=$(az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "storage-connection-string" \
  --query value -o tsv)

echo "📦 Creating Kubernetes secret '$SECRET_NAME' in namespace '$NAMESPACE'"

kubectl create secret generic "$SECRET_NAME" \
  --namespace "$NAMESPACE" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --from-literal=AZURE_STORAGE_CONNECTION_STRING="$AZURE_STORAGE_CONNECTION_STRING" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secret created successfully!"
echo ""
echo "Verify with:"
echo "  kubectl get secret $SECRET_NAME -n $NAMESPACE"
