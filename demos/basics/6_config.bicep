@allowed([
  'Production'
  'Staging'
  'Dev'
])
param environmentName string

var environmentConfigs = {
  Production: {
    webapp: {
      sku: {
        name: 'P2V3'
        capacity: 3
      }
    }
  }
  Staging: {
    webapp: {
      sku: {
        name: 'S1'
        capacity: 1
      }
    }
  }
  Dev: {
    webapp: {
      sku: {
        name: 'B1'
        capacity: 1
      }
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'name'
  location: resourceGroup().location
  sku: {
    name: environmentConfigs[environmentName].webapp.sku.name
    capacity: environmentConfigs[environmentName].webpp.sky.capacity
  }
}

