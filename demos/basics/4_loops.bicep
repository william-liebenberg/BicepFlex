// -------------
// integer index
// -------------

param storageCount int = 2

var baseName = 'storage${take(uniqueString(resourceGroup().id), 6)}'

module stgModule1 'storageAccount.bicep' = [for i in range(0, storageCount): {
  name: 'deploy${baseName}-${i}'
  params: {
    storageAccountName: 'deploy${baseName}${i}'
  }
}]

























// --------------
// array elements
// --------------

param storageNames array = [
  'wicksy'
  'goldie'
  'cookie'
  'greentree'
]

module stgModule2 'storageAccount.bicep' = [for name in storageNames: {
  name: 'deploy-${name}'
  params: {
    storageAccountName: '${name}${take(uniqueString(resourceGroup().id), 6)}'
  }
}]





































// ---------------
// array and index
// ---------------
var storageConfigurations = [
  {
    suffix: 'local'
    sku: 'Standard_LRS'
  }
  {
    suffix: 'geo'
    sku: 'Standard_GRS'
  }
]

resource storageAccountResources 'Microsoft.Storage/storageAccounts@2021-02-01' = [for (config, i) in storageConfigurations: {
  name: 'sa${config.suffix}${i}'
  location: resourceGroup().location
  sku: {
    name: config.sku
  }
  kind: 'StorageV2'
}]
