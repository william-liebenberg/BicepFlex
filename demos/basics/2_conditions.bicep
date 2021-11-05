@description('Use geo-replication for storage')
param enableGeoReplication bool = true

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'name'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    // conditionally assign geo repl sku name 
    name: enableGeoReplication ? 'Standard_GRS' : 'Premium_LRS'
  }
}


