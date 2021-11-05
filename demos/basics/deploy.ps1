$resourceGroupName="Ndc2021Storage"

az group create --name $resourceGroupName --location australiaeast

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file storageAccount.bicep `
    --parameters storageAccountName=ndc2021storage `
    --query properties.outputs