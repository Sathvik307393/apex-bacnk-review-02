// ============================================================
// NexaBank - Azure Infrastructure (Bicep)
// Provisions: AKS Cluster, ACR, PostgreSQL,
//             Blob Storage, Key Vault, Log Analytics
// ============================================================

@description('Environment name prefix (e.g. nexabank)')
param envName string = 'nexabank'

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('PostgreSQL administrator login')
param dbAdminLogin string = 'nexaadmin'

@description('PostgreSQL administrator password')
@secure()
param dbAdminPassword string

@description('JWT secret for token signing')
@secure()
param jwtSecret string

@description('Number of AKS system nodes')
param aksNodeCount int = 2

@description('AKS node VM size')
param aksNodeVmSize string = 'Standard_D2s_v3'

// ─── Names ────────────────────────────────────────────────────────────────────
var acrName = '${replace(envName, '-', '')}acr'
var logName = '${envName}-logs'
var aksName = '${envName}-aks'
var dbServerName = '${envName}-postgres'
var dbName = 'apex_bank'
var storageAccountName = '${replace(envName, '-', '')}storage'
var keyVaultName = '${envName}-kv'

// ─── Log Analytics Workspace ─────────────────────────────────────────────────
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logName
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

// ─── Azure Container Registry ─────────────────────────────────────────────────
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: { name: 'Basic' }
  properties: {
    adminUserEnabled: true
  }
}

// ─── AKS Cluster ──────────────────────────────────────────────────────────────
resource aks 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.29'
    dnsPrefix: '${envName}-aks'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'system'
        count: aksNodeCount
        vmSize: aksNodeVmSize
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: true
        minCount: 2
        maxCount: 5
        nodeTaints: []
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

// ─── Attach ACR to AKS (AcrPull role) ────────────────────────────────────────
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, aks.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// ─── PostgreSQL Flexible Server ───────────────────────────────────────────────
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: dbServerName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: dbAdminLogin
    administratorLoginPassword: dbAdminPassword
    version: '15'
    storage: { storageSizeGB: 32 }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: { mode: 'Disabled' }
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
    }
  }
}

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-03-01-preview' = {
  name: dbName
  parent: postgresServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// Allow Azure services (AKS outbound IPs) to connect
resource postgresFirewallAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-03-01-preview' = {
  name: 'AllowAzureServices'
  parent: postgresServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// ─── Azure Blob Storage ───────────────────────────────────────────────────────
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource kycContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'kyc-documents'
  parent: blobService
  properties: { publicAccess: 'None' }
}

resource processedContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'processed-and-validated-container'
  parent: blobService
  properties: { publicAccess: 'None' }
}

// ─── Key Vault ────────────────────────────────────────────────────────────────
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    accessPolicies: []
    enableRbacAuthorization: true
  }
}

resource kvSecretDb 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'db-password'
  parent: keyVault
  properties: { value: dbAdminPassword }
}

resource kvSecretJwt 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'jwt-secret'
  parent: keyVault
  properties: { value: jwtSecret }
}

resource kvSecretStorage 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'storage-connection-string'
  parent: keyVault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────
output acrLoginServer string = acr.properties.loginServer
output acrName string = acr.name
output aksName string = aks.name
output aksResourceGroup string = resourceGroup().name
output dbHost string = postgresServer.properties.fullyQualifiedDomainName
output dbName string = dbName
output dbAdminLogin string = dbAdminLogin
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
