param location string = 'WestUS2'

@description('Name of this project')
param projectName string

@description('The environment that this project is being deployed to. (eg. Dev, Test, Staging, Prod)')
param environmentName string

//@description('Datacenter location for your azure resources')
//param location string = resourceGroup().location

@description('Resource tags for organizing / cost monitoring')
param tags object

@allowed([
  'Basic'
  'S0'
  'S1'
  'S2'
  'P1'
  'P2'
  'P3'
])
param performanceTier string = 'Basic'

@description('Name of the KeyVault instance where we want to store secrets')
param keyVaultName string

@description('Date timestamp of when this deployment was run - defaults to UtcNow()')
param timestamp string = utcNow('yyMMddHHmmss')

var sqlServerName = '${projectName}-sqlserver-${environmentName}'
var sqlDatabseName = '${projectName}-sqlserver-${environmentName}'

var sqlAdminUsername = 'secretadmin'
var entropy = uniqueString(timestamp)
var sqlAdminPassword = '#${take(entropy,12)}X!'

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' ={
  name: sqlServerName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${sqlServerName}/${sqlDatabseName}'
  location: location
  tags: tags
  sku: {
    name: performanceTier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  dependsOn: [
    sqlServer
  ]
}

// Add the SQL connection string to KeyVault
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyvault.name}/ConnectionStrings--DefaultConnection'
  tags: tags
  properties: {
    value: 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabseName};User Id=${sqlAdminUsername};Password=${sqlAdminPassword};'
    contentType: 'string'
    attributes: {
      enabled: true
    }
  }
}
