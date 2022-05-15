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

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
])
param storageSku string = 'Standard_LRS'

// randomness added to the end of storage account names
var entropy = uniqueString('${subscription().id}${resourceGroup().id}')

var attachmentStorageAccountName = replace(replace(toLower(take('${projectName}${environmentName}${entropy}', 24)), '-', ''), '_', '')
var attachmentsBlobContainerName = 'attachments'

resource attachmentStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: attachmentStorageAccountName
  location: location
  kind: 'StorageV2'
  tags: tags
  sku: {
    name: storageSku
  }
  properties: {
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource attachmentsBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${attachmentStorageAccountName}/default/${attachmentsBlobContainerName}'
  dependsOn: [
    attachmentStorageAccount
  ]
  properties: {
    publicAccess: 'Blob'
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName

  // Add the Storage Account connection string to KeyVault
  resource attachmentStorageAccountConnectionStringSecret 'secrets' = {
    name: 'ConnectionStrings--AttachmentsStorageAccount'
    tags: tags
    properties: {
      value: 'DefaultEndpointsProtocol=https;AccountName=${attachmentStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(attachmentStorageAccount.id, attachmentStorageAccount.apiVersion).keys[0].value}'
      contentType: 'string'
      attributes: {
        enabled: true
      }
    }
  }
}

output attachmentsStorageAccountId string = attachmentStorageAccount.id
output attachmentsStorageAccountName string = attachmentStorageAccount.name
output attachmentsBlobContainerName string = attachmentsBlobContainer.name
output attachmentsBlobContainerId string = attachmentsBlobContainer.id
