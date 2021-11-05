// BICEP Template to create all the resources required to host the project

targetScope = 'resourceGroup'

// project name
@minLength(3)
@maxLength(21)
@description('Name of this project')
param projectName string

// environment name like dev, staging, prod
@allowed([
  'dev'
  'test'
  'staging'
  'training'
  'prod'
])
@description('The environment that this project is being deployed to. (eg. Dev, Test, Staging, Prod)')
param environmentName string

@description('Date timestamp of when this deployment was run - defaults to UtcNow()')
param lastDeploymentDate string = utcNow('yyMMddHHmmss')

@description('Resource tags for organizing / cost monitoring')
param tags object = {
  project: projectName
  environment: environmentName
  lastDeploymentDate: lastDeploymentDate
}

@description('Secret API Key - to be stored in KeyVault')
@secure()
param secretApiKey string = ''

@description('The desired performance tier for the SQL Database')
@allowed([
  'Basic'
  'S0'
  'S1'
  'S2'
  'P1'
  'P2'
  'P3'
])
param databasePerformanceTier string = 'Basic'

@description('The desired performance tier for the WebApp')
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
param webappPerformanceTier string = 'P1V2'

// Call a separate bicep file to deploy the KeyVault and secrets
module keyVault 'br:bicepflex.azurecr.io/bicep/modules/keyvault:v1.2' = {
  name: '${projectName}-keyVault-${lastDeploymentDate}'
  scope: resourceGroup()
  params: {
    environmentName: environmentName
    projectName: projectName
    tags: tags
    secretApiKey: secretApiKey
  }
}

// Call a separate bicep file to deploy the attachment storage account
module storage 'br:bicepflex.azurecr.io/bicep/modules/storage:v1.2' = {
  name: '${projectName}-storage-${lastDeploymentDate}'
  scope: resourceGroup()
  params: {
    environmentName: environmentName
    projectName: projectName
    tags: tags
    storageSku: 'Standard_LRS'
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

module database 'br:bicepflex.azurecr.io/bicep/modules/sqldatabase:v1.2' = {
  name: '${projectName}-database-${lastDeploymentDate}'
  scope: resourceGroup()
  params: {
    environmentName: environmentName
    projectName: projectName
    tags: tags
    performanceTier: databasePerformanceTier
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

module webapp 'br:bicepflex.azurecr.io/bicep/modules/webapp:v1.2' = {
  name: '${projectName}-webapp-${lastDeploymentDate}'
  scope: resourceGroup()
  params: {
    environmentName: environmentName
    projectName: projectName
    tags: tags
    serverSku: webappPerformanceTier
    keyVaultName: keyVault.outputs.keyVaultName
    keyVaultUri: keyVault.outputs.keyVaultUri
    attachmentsBlobContainerName: storage.outputs.attachmentsBlobContainerName
    attachmentsBlobContainerId: storage.outputs.attachmentsBlobContainerId
  }
}

output webappName string = webapp.outputs.webappName
output webappUrl string = webapp.outputs.webappUrl
