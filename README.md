# NexaBank — Enterprise Azure Architecture

Welcome to **NexaBank**, a cloud-native microservices banking application. This project is designed using a production-ready, highly secure, scalable, and **Zone-Redundant (High Availability)** architecture on Microsoft Azure.

---

## 🏛️ Comprehensive Architecture

The infrastructure is broken down into five core pillars, all designed with **Availability Zones (AZs)** in mind to ensure zero downtime even if a physical Azure datacenter fails.

### 1. Networking & Edge
*The foundational layer isolating and protecting our resources.*
- **Azure Virtual Network (VNet):** A private, isolated network containing dedicated subnets for Kubernetes nodes, the database, private endpoints, and the Application Gateway.
- **Azure Application Gateway (AGW):** A Layer-7 web traffic load balancer serving as the public entry point. It provides custom domain hosting, SSL/TLS termination, and Web Application Firewall (WAF) protection.
- **Public IP Address:** Associated with the Application Gateway to route external user traffic.

### 2. Compute & Orchestration
*Where the application code and business logic run.*
- **Azure Kubernetes Service (AKS):** The core orchestrator running our microservices (`api-gateway`, `auth`, `user`, `transactions`, `kyc`, `audit`, `admin`). Deployed within the VNet using **Azure CNI**, spanning across **Availability Zones 1, 2, and 3** for high availability, and connected to the Application Gateway via AGIC.
- **Azure Container Registry (ACR):** A secure, private registry (**Premium SKU** for zone redundancy) storing the Docker images for our AKS cluster.
- **Azure Functions (Serverless):** An event-driven serverless function that automatically triggers when a new KYC document is uploaded to the Storage Account. It processes the document and moves it to the validated container, decoupling heavy processing from the AKS cluster.

### 3. Data & Storage
*Secure, highly available persistence layers.*
- **Azure Database for PostgreSQL (Flexible Server):** A fully managed relational database serving as the source of truth for user data and transactions. It is configured with **Zone-Redundant High Availability** (creating a synchronous standby replica in another zone) and is injected directly into a delegated VNet subnet.
- **Azure Storage Account (Blob Storage):** Configured with **Zone-Redundant Storage (ZRS)** to ensure KYC documents survive datacenter-level failures. Contains the `kyc-documents` (raw uploads) and `processed-and-validated` containers.

### 4. Messaging & Eventing
*Decoupling asynchronous workflows for better resilience.*
- **Azure Service Bus:** An enterprise message broker. After the Azure Function finishes processing a KYC document, it publishes an event/message to a Service Bus Queue. Another service then picks up this message to asynchronously email the user with their KYC status (Approved/Rejected), preventing the document processor from hanging on email delivery.

### 5. Security & Identity
*Zero-trust access and secrets management.*
- **Microsoft Entra ID (Managed Identities):** Provides passwordless, identity-based authentication. The AKS cluster and Azure Function use system-assigned Managed Identities to securely read secrets from Key Vault, blobs from Storage, and publish messages to the Service Bus.
- **Azure Key Vault:** A centralized, hardware-backed vault storing sensitive configuration like the PostgreSQL admin password and the JWT signing keys.

### 6. Observability (Azure Monitor)
*Deep insights into performance and health.*
- **Managed Prometheus & Grafana:** Provides advanced, real-time metrics scraping and stunning visualization dashboards for Kubernetes node and pod performance. Azure Managed Grafana is integrated natively with the AKS cluster.
- **Log Analytics Workspace:** The central sink for all infrastructure telemetry, including AKS container logs, network flow logs, and database metrics.
- **Application Insights:** Application Performance Monitoring (APM) providing distributed tracing, exception tracking, and dependency mapping across the microservices and Azure Functions.

---

## 🚀 Setup & Deployment

Currently, the deployment strategy follows a two-phase learning and execution approach:

### Phase 1: Manual Portal Exploration
Before writing infrastructure-as-code, it is highly recommended to explore the Azure Portal to understand how these 5 pillars interconnect. 
*See `azure_portal_manual_setup.md` in the artifacts directory for step-by-step instructions on creating this exact architecture manually.*

### Phase 2: Terraform Automation
Once the manual setup is understood, the infrastructure will be automated using **Terraform**. 
- The Terraform scripts will programmatically provision the entire architecture listed above in a single, repeatable manner.
- *(Note: We are deploying to a single default environment for now, so Terraform workspaces are not utilized).*

---

## 🛠️ Local Development

To spin up the microservices locally without Azure dependencies:
```bash
docker-compose up --build
```
This will start the local API Gateway on `http://localhost:3000` along with a local PostgreSQL container.