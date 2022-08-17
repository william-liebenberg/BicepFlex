// module deployed at tenant level
module exampleModule 'managementGroup.bicep' = {
  name: 'deployToTenant'
  scope: tenant()
}


/// SCRAP SCOPE -> SUBSCRIPTION
/// SCRAP SCOPE -> TENANT
