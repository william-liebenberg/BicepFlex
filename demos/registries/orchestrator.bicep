var baseName = 'webapp${take(uniqueString(resourceGroup().id), 6)}'

module webapp 'br:bicepflex.azurecr.io/bicep/modules/fullstack-webapp:v1.2' = {
  name: 'deploy${baseName}'
  params: {
    tags: {
      module: 'Fullstack-webapp'
      version: 'v1.2'
      event: 'NDCSydney2021'
    }
    projectName: 'NDCSydney2021'
    environmentName: 'prod'
    databasePerformanceTier: 'Basic'
    webappPerformanceTier: 'P1V2'
    secretApiKey: '12134'
  }
}

output url string = webapp.outputs.webappUrl
