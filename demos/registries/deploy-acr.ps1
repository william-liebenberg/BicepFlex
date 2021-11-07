param (
	[Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$RegistryName
)

Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name $ResourceGroup --location australiaeast

Write-Host
Write-Host "🔨 - BicepFlex Azure Container Registry" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file acr.bicep `
    --parameters acrName=$RegistryName `
    --verbose `
    --query properties.outputs

Write-Host
Write-Host "✔️ - Done" -ForegroundColor Green