param projectName string = 'NETUG2022'
param environmentName string = 'test'
param tags object = {
  module: 'fullstack-webapp'
  event: 'Melbourne Livestream'
}

var baseName = 'webapp${take(uniqueString(resourceGroup().id), 6)}'

module webapp 'br:acrnetug2022.azurecr.io/bicep/modules/fullstack-webapp:v1.2' = {
  name: 'deploy-${baseName}'
  params: {
    tags: tags
    projectName: projectName
    environmentName: environmentName
    databasePerformanceTier: 'S0'
    webappPerformanceTier: 'P1V2'
    secretApiKey: '12134'
  }
}

output url string = webapp.outputs.webappUrl
