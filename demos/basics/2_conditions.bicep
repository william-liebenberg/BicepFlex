@description('Use geo-replication for storage')
param enableGeoReplication bool = true

param needAStorageAccount bool = false

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if(needAStorageAccount) {
  name: 'name'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    // conditionally assign geo repl sku name 
    name: enableGeoReplication ? 'Standard_GRS' : 'Premium_LRS'
  }
}
