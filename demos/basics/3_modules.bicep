var baseName = 'storage${take(uniqueString(resourceGroup().id), 6)}'

module stgModule1 'storageAccount.bicep' = {
  name: 'deploy${baseName}'
  params: {
    storageAccountName: 'deploy${baseName}'
  }
}

output saname string = stgModule1.outputs.storageAccountName
