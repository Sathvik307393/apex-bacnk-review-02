# NexaBank — AKS Deployment Guide

## Prerequisites

| Tool | Min Version | Install |
|------|-------------|---------|
| Azure CLI | 2.55+ | [docs.microsoft.com/cli/azure/install-azure-cli](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| kubectl | 1.29+ | `az aks install-cli` |
| Docker Desktop | 24+ | [docker.com/get-started](https://www.docker.com/get-started) |
| Bicep CLI | 0.24+ | `az bicep install` |

---

## Step 1 — One-Time Azure Setup

```bash
# Login
az login

# Set your subscription
az account set --subscription "<YOUR_SUBSCRIPTION_NAME>"

# Create Resource Group
az group create \
  --name nexabank-rg \
  --location eastus
```

---

## Step 2 — Provision All Azure Resources (Bicep)

```bash
az deployment group create \
  --resource-group nexabank-rg \
  --template-file azure/main.bicep \
  --parameters \
      envName=nexabank \
      location=eastus \
      dbAdminLogin=nexaadmin \
      dbAdminPassword="<STRONG_PASSWORD_MIN_8_CHARS>" \
      jwtSecret="<RANDOM_64_CHAR_STRING>" \
      aksNodeCount=2 \
      aksNodeVmSize=Standard_D2s_v3
```

> **What gets created:**
> AKS cluster (2-node, auto-scaling 2–5), ACR, PostgreSQL Flexible Server,
> Blob Storage (kyc-documents + processed-and-validated-container),
> Key Vault with all 3 secrets pre-loaded, Log Analytics + Container Insights.

View outputs:
```bash
az deployment group show \
  --resource-group nexabank-rg \
  --name main \
  --query properties.outputs
```

---

## Step 3 — Initialize the Database

```bash
DB_HOST=$(az postgres flexible-server show \
  --resource-group nexabank-rg \
  --name nexabank-postgres \
  --query fullyQualifiedDomainName -o tsv)

psql "host=$DB_HOST port=5432 dbname=apex_bank user=nexaadmin sslmode=require" \
  -f init.sql
```

---

## Step 4 — Connect kubectl to AKS

```bash
az aks get-credentials \
  --resource-group nexabank-rg \
  --name nexabank-aks \
  --overwrite-existing

# Verify
kubectl get nodes
# Expected: 2 nodes in Ready state
```

---

## Step 5 — Build & Push Docker Images to ACR

```bash
ACR_NAME=nexabankacr
ACR_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
az acr login --name $ACR_NAME

# Build and push all 8 images from the repo root
SERVICES=(api-gateway auth user transactions kyc document-processor audit admin)
for svc in "${SERVICES[@]}"; do
  echo "▶ Building nexa-$svc..."
  docker build \
    -f services/$svc/Dockerfile \
    -t $ACR_SERVER/nexa-$svc:latest \
    .
  docker push $ACR_SERVER/nexa-$svc:latest
done
```

---

## Step 6 — Apply Kubernetes Manifests

```bash
# 1. Create namespace
kubectl apply -f k8s/00-namespace.yaml

# 2. Apply ConfigMap (non-sensitive env vars)
kubectl apply -f k8s/01-configmap.yaml

# 3. Create Kubernetes secret from Key Vault (uses the helper script)
chmod +x azure/create-k8s-secret.sh
./azure/create-k8s-secret.sh

# 4. Deploy all services
kubectl apply -f k8s/services/

# 5. Watch rollout
kubectl rollout status deployment --namespace nexabank --timeout=180s
```

---

## Step 7 — Verify Deployment

```bash
# Check all pods are Running
kubectl get pods -n nexabank

# Get the public IP of the API Gateway
kubectl get svc nexa-api-gateway -n nexabank
# Wait for EXTERNAL-IP to be assigned (1-2 minutes)

# Health check
GATEWAY_IP=$(kubectl get svc nexa-api-gateway -n nexabank \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "App URL: http://$GATEWAY_IP"
curl http://$GATEWAY_IP/health
# Expected: {"status":"healthy","timestamp":"...","services":{...}}
```

---

## Step 8 — Update Images (Rolling Redeploy)

When you push code changes:
```bash
# Build and push new image
docker build -f services/auth/Dockerfile -t $ACR_SERVER/nexa-auth:v2 .
docker push $ACR_SERVER/nexa-auth:v2

# Rolling update (zero downtime)
kubectl set image deployment/nexa-auth \
  auth=$ACR_SERVER/nexa-auth:v2 \
  --namespace nexabank

kubectl rollout status deployment/nexa-auth -n nexabank
```

---

## Step 9 — Set Up GitHub Actions CI/CD (Optional)

Add these secrets to **GitHub → Settings → Secrets → Actions**:

| Secret Name | Value |
|---|---|
| `AZURE_CREDENTIALS` | `az ad sp create-for-rbac --name nexabank-sp --role contributor --scopes /subscriptions/<SUB_ID>/resourceGroups/nexabank-rg --sdk-auth` |
| `ACR_LOGIN_SERVER` | `nexabankacr.azurecr.io` |
| `ACR_USERNAME` | ACR admin username |
| `ACR_PASSWORD` | ACR admin password |
| `AZURE_RESOURCE_GROUP` | `nexabank-rg` |
| `AKS_CLUSTER_NAME` | `nexabank-aks` |
| `DB_PASSWORD` | PostgreSQL admin password |
| `JWT_SECRET` | JWT signing key |
| `AZURE_STORAGE_CONNECTION_STRING` | Storage account connection string |

Push to `main` → CI/CD builds all images and deploys automatically.

---

## Useful kubectl Commands

```bash
# View all resources in namespace
kubectl get all -n nexabank

# View logs for a service
kubectl logs -l app=nexa-auth -n nexabank --tail=100 -f

# Shell into a pod
kubectl exec -it deploy/nexa-auth -n nexabank -- /bin/sh

# Scale a deployment
kubectl scale deployment nexa-api-gateway --replicas=3 -n nexabank

# View events (useful for debugging)
kubectl get events -n nexabank --sort-by='.lastTimestamp'

# Describe a failing pod
kubectl describe pod -l app=nexa-auth -n nexabank
```

---

## Azure Resources Required

| # | Resource | Azure Service | Purpose |
|---|---|---|---|
| 1 | `nexabank-rg` | Resource Group | Container for all resources |
| 2 | `nexabankacr` | Container Registry (Basic) | Docker image repository |
| 3 | `nexabank-logs` | Log Analytics Workspace | Centralized logging |
| 4 | `nexabank-aks` | AKS Cluster (2× D2s_v3) | Kubernetes orchestrator |
| 5 | `nexabank-postgres` | PostgreSQL Flexible Server | Relational database |
| 6 | `nexabankstorage` | Storage Account (Standard LRS) | Blob file storage |
| 7 | `kyc-documents` | Blob Container | Raw KYC document uploads |
| 8 | `processed-and-validated-container` | Blob Container | Validated documents |
| 9 | `nexabank-kv` | Key Vault (Standard) | Secrets management |

**Total Azure resources: 9** *(+ K8s resources managed by AKS)*

---

## Estimated Monthly Cost (East US)

| Resource | SKU | Est/mo |
|---|---|---|
| AKS control plane | Free | $0 |
| 2× Standard_D2s_v3 nodes | Pay-as-you-go | ~$140 |
| PostgreSQL Flexible Server | Standard_B1ms | ~$15 |
| Storage Account | Standard LRS | < $1 |
| Container Registry | Basic | ~$5 |
| Key Vault | Standard | ~$1 |
| Azure Load Balancer (Standard) | ~$5 |
| Log Analytics | Pay-per-GB | ~$2 |
| **Total** | | **~$169/mo** |
