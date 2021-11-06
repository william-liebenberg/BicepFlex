Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name BicepFlex-NDCSydney2021-staging --location australiaeast

Write-Host
Write-Host "🔨 - Deploying BicepFlex Fullstack WebApp" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --resource-group BicepFlex-NDCSydney2021-staging `
    --template-file fullstack-webapp.bicep `
    --parameters projectName=ndc2021bicepflex environmentName=staging secretApiKey=1234 `
    --query properties.outputs

Write-Host
Write-Host "✔️ - Done" -ForegroundColor Green