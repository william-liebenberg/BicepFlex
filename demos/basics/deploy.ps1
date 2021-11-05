az group create --name MyResourceGroup --location australiaeast

az deployment group create `
    --resource-group MyResourceGroup `
    --template-file storageAccount.bicep `
    --parameters storageAccountName=ndc2021storage `
    --query properties.outputs