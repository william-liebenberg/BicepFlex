// ------------------------------------------
// resource deployed to target resource group
//
// az deployment group create \
//   --name AzSydneyUG-Deployment \
//   --resource-group AzSydneyUG \
//   --template-file scopes.bicep
//
// ------------------------------------------
module exampleModule1 'storageAccount.bicep' = {
  name: 'thisRG'
  params: {
    storageAccountName: 'saInThisRG'
  }
}

// ----------------------------------------------------------
// module deployed to resource group in the same subscription
// ----------------------------------------------------------
param otherResourceGroup string
module exampleModule2 'storageAccount.bicep' = {
  name: 'otherRG'
  scope: resourceGroup(otherResourceGroup)
  params: {
    storageAccountName: 'saInOtherRG'
  }
}

// ------------------------------------------------------------
// module deployed to different subscription and resource group
// ------------------------------------------------------------
param otherSubscriptionID string
module exampleModule3 'storageAccount.bicep' = {
  name: 'otherSubAndRG'
  scope: resourceGroup(otherSubscriptionID, otherResourceGroup)
  params: {
    storageAccountName: 'saInOtherSubAndRG'
  }
}
