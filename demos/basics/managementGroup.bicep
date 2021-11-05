targetScope = 'tenant'

param mgName string = 'mg-${uniqueString(newGuid())}'

// ManagementGroup deployed at tenant
resource managementGroup 'Microsoft.Management/managementGroups@2020-05-01' = {
  scope: tenant()
  name: mgName
  properties: {}
}

output output string = mgName
