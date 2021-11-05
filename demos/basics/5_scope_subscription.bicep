// ------------------------------------------------------------
// deploy a new resource group to the current subscription
// ------------------------------------------------------------
targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string

resource newRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}
