@description('Name of this project')
param projectName string

@description('The environment that this project is being deployed to. (eg. Dev, Test, Staging, Prod)')
param environmentName string

@description('Datacenter location for your azure resources')
param location string = resourceGroup().location

@description('Resource tags for organizing / cost monitoring')
param tags object

@description('Name of the KeyVault instance where we want to store secrets')
param keyVaultName string

@description('Full URI of the KeyVault instance that the WebApp will use for accessing secrets')
param keyVaultUri string

@description('Full Resource ID of the Blob Storage Container used for storing attachments')
param attachmentsBlobContainerId string

@description('The full name of the blob storage container used for attachments')
param attachmentsBlobContainerName string

@allowed([
  'B1'
  'B2'
  'B3'
  'D1'
  'F1'
  'FREE'
  'I1'
  'I1v2'
  'I2'
  'I2v2'
  'I3'
  'I3v2'
  'P1V2'
  'P1V3'
  'P2V2'
  'P2V3'
  'P3V2'
  'P3V3'
  'PC2'
  'PC3'
  'PC4'
  'S1'
  'S2'
  'S3'
])
param serverSku string = 'P1V2'

var webappName = '${projectName}-${environmentName}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: webappName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: webappName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    DisableLocalAuth: true
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: webappName
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: serverSku
    capacity: 1
  }
}

resource webapp 'Microsoft.Web/sites@2021-01-01' = {
  name: webappName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  //  "api", "app", "app,linux", "functionapp", "functionapp,linux"
  kind: 'app,linux'
  properties: {
    serverFarmId: servicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'KeyVaultUri'
          value: keyVaultUri
        }
      ]
    }
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: webapp.identity.tenantId
        objectId: webapp.identity.principalId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
  }
}

// Storage Blob Data Contributor
var storageBlobDataContributorRoleName = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource attachmentsBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' existing = {
  name: attachmentsBlobContainerName
}

resource attachmentBlobStorageRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageBlobDataContributorRoleName, attachmentsBlobContainerId)
  scope: attachmentsBlobContainer
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleName)
    principalId: webapp.identity.principalId
  }
}

// Monitoring Metrics Publisher
var monitoringMetricsPublisherRoleName = '3913510d-42f4-4e42-8a64-420c390055eb'

resource monitoringMetricsPublisherRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(monitoringMetricsPublisherRoleName, appInsights.id)
  scope: appInsights
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringMetricsPublisherRoleName)
    principalId: webapp.identity.principalId
  }
}

output webappName string = webappName
output webappUrl string = 'https://${webapp.properties.defaultHostName}'
