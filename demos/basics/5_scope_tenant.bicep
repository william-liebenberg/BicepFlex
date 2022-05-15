// ------------------------------------------------------------
// module deployed at tenant level
//
// see: https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-tenant
// ------------------------------------------------------------

module exampleModule 'managementGroup.bicep' = {
  name: 'deployToTenant'
  scope: tenant()
}
