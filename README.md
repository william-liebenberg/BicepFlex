# Flexing your Biceps with Azure

Source code and slides from my NDC Sydney 2021 talk - [Flexing your Biceps with Azure](https://ndcsydney.com/agenda/flexing-your-biceps-with-azure-0p4l/0alw1a94vk5)

## Demos

### Basics

The `demos/basics` folder contains sample `.bicep` files that demonstrate most of the programming constructs available in Azure Bicep.

For a complete reference, check out the Azure Bicep [Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/).

### Registries

Run `deploy-acr.ps1` to provision an Azure Container Registry that you can use for publishing and referencing Bicep modules.

Once complete, modify the `moduleAliases` section of the `fullstack-webapp/bicepconfig.json` file to insert your ACR Server Name:

```json
  "moduleAliases": {
    "br": {
      "bicepflex": {
        "registry": "<YOUR ACR SERVER NAME>.azurecr.io",
        "modulePath": "bicep/modules"
      }
    }
  }
```

By adding a module alias, we are able to simplify the module references in our bicep files.

```bicep
// module <symbolic name> 'br/<alias>:<module>:<tag>
module keyVault 'br/bicepflex:keyvault:v1.0' = { ... }

// instead of:
module keyVault 'br:bicepflex.azurecr.io/bicep/modules/keyvault:v1.0' = { ... }
```

> For full reference of the `bicepconfig.json` file check out the [documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config).

To publish all the modules, run the `fullstack-webapp/publish-modules.ps1` file and pass in the ACR Server Name and version tag values.

Once your modules are published, you are able to deploy the `webapp-orchestrator.bicep` file by running the `deploy-webapp.ps1` script. This script deploys a full-stack web application using a single module reference. Awesome!

## Bicep Template and GitHub Workflow

The `.azure` folder contains the `azureDeploy.bicep` file that provisions the following reasources:

1. StorageAccount
2. AppInsights with LogAnalytics workspace
3. Linux Azure Functions consumption plan
4. Linux Azure Functions app
5. Role assignment for `Storage Blob Data Contributor` for the functions app to be able to interact with the storage account securely without using the standard `AzureWebJobStorage` connection string
6. Role assignment for `Monitoring Metrics Publisher` between the functions app and Application Insights (to enable Azure Active Directory Authentication for Application Insights `DisableLocalAuth: false`)

The example GitHub workflow [`cicd.yml`](./.github/workflows/cicd.yml) shows how you can execute jobs to:

1. Run the [Bicep Linter](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/linter) - for enforcing best practices to your Bicep code
2. Validate that your Bicep template is syntactically correct
3. Preview resource changes ([What-If Deployments](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if?tabs=azure-powershell%2CCLI)) by comparing the difference between the current and future state of the resources.
4. Deploy the Bicep template to provision the required Azure Resources:
   1. The Storage Account has public blob access disabled
   2. The Azure Function application's `Managed Identity` is added to the storage account `Access control (IAM)` via a `roleAssignment` for the role `Storage Blob Data Contributor`. This gives the Azure Functions application permissions needed to operate correctly without the full `AzureWebJobsStorage` connection string. The only required appsetting is `AzureWebJobsStorage__accountName` that is assigned to `storageAccount.name`
5. Build the Azure Functions application and save a deployable artifact
6. Deploy the Azure Functions application artifact to the Azure Functions blob storage account and set the application `WEBSITE_RUN_FROM_PACKAGE` setting to the url of the artifact blob.

## Source Code

The `src` folder simply contains the default Azure Functions HttpTrigger template application. It is the application that gets built and deployed from the GitHub workflow [`cicd.yml`](./.github/workflows/cicd.yml).

DONE!
