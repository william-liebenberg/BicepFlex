// module deployed at tenant level
module exampleModule 'managementGroup.bicep' = {
  name: 'deployToTenant'
  scope: tenant()
}
