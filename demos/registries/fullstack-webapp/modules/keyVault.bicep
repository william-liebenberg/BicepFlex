@description('Name of this project')
param projectName string

@description('The environment that this project is being deployed to. (eg. Dev, Test, Staging, Prod)')
param environmentName string

@description('Datacenter location for your azure resources')
param location string = resourceGroup().location

@description('Resource tags for organizing / cost monitoring')
param tags object

@secure()
param secretApiKey string = ''

var keyvaultName = '${projectName}-${environmentName}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    enabledForTemplateDeployment: true
    createMode: 'default'
    tenantId: subscription().tenantId
    accessPolicies: [ ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource superSecretApiKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/Secrets--ApiKey'
  tags: tags
  properties: {
    value: secretApiKey
    contentType: 'string'
    attributes: {
      enabled: true
    }
  }
}

output keyVaultName string = keyvaultName
output keyVaultUri string = keyVault.properties.vaultUri
