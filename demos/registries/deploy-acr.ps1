Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name BicepFlexRegistry --location australiaeast

Write-Host
Write-Host "🔨 - BicepFlex Azure Container Registry" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --resource-group BicepFlexRegistry `
    --template-file acr.bicep `
    --parameters acrName=BicepFlex `
    --query properties.outputs

Write-Host
Write-Host "✔️ - Done" -ForegroundColor Green