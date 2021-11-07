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
param secretApiKey string

@description('The desired performance tier for the SQL Database')
param databasePerformanceTier string = 'Basic'

@description('The desired performance tier for the WebApp')
param webappPerformanceTier string = 'P1V2'

// Call a separate bicep file to deploy the KeyVault and secrets
// notice we are using the module alias to shorten the reference
module keyVault 'br/bicepflex:keyvault:v1.0' = {
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
// notice we are using the module alias to shorten the reference
module storage 'br/bicepflex:storage:v1.0' = {
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

// notice we are using the module alias to shorten the reference
module database 'br/bicepflex:sqldatabase:v1.0' = {
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

// notice we are using the module alias to shorten the reference
module webapp 'br/bicepflex:webapp:v1.0' = {
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
