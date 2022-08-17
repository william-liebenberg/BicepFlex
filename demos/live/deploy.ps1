param (
	[Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "netug2022-live",

    [Parameter(Mandatory = $false)]
    [string]$ProjectName = "netug2022-live",

    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName = "live",

    [Parameter(Mandatory = $false)]
    [string]$Location = "australiaeast"
)

Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name $ResourceGroup --location $Location

Write-Host
Write-Host "🔨 - Deploying Bicep file" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --name 'deploy-livedemo-netug2022' `
    --resource-group $ResourceGroup `
    --template-file storage.bicep `
    --parameters projectName="$($ProjectName)" environmentName="$($EnvironmentName)" `
    --verbose `
    --query properties.outputs `
    --output yaml

Write-Host
Write-Host "✅ - Done" -ForegroundColor Green