param (
	[Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "netug2022",

    [Parameter(Mandatory = $false)]
    [string]$RegistryName = "acrnetug2022"
)

Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name $ResourceGroup --location australiaeast

Write-Host
Write-Host "📦 - Deploying Azure Container Registry" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --name 'deploy-acr-netug2022' `
    --resource-group $ResourceGroup `
    --template-file acr.bicep `
    --parameters acrName=$RegistryName `
    --verbose `
    --query properties.outputs

Write-Host
Write-Host "✅ - Done" -ForegroundColor Green