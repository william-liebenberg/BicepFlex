@description('Specify the location for the function application resources')
param location string = resourceGroup().location

@description('Specify the name of the function application')
param functionAppName string = 'fnapp${uniqueString(resourceGroup().id)}'

var storageAccountName = toLower(take('${functionAppName}${uniqueString(resourceGroup().id)}', 24))
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
  }
}

var funcAppHostingPlanName = functionAppName
resource funcAppHostingPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: funcAppHostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    serverFarmId: funcAppHostingPlan.id
    siteConfig: {
      http20Enabled: true
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
      ]
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: functionAppName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: functionAppName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    DisableLocalAuth: true
  }
}

// Storage Blob Data Contributor
var storageBlobDataContributorRoleName = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource blobStorageRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageBlobDataContributorRoleName, storageAccount.id)
  scope: storageAccount
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleName)
    principalId: functionApp.identity.principalId
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
    principalId: functionApp.identity.principalId
  }
}

output principalId string = functionApp.identity.principalId
output functionAppName string = functionApp.name
