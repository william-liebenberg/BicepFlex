param (
	[Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "netug2022live",

    [Parameter(Mandatory = $false)]
    [string]$ProjectName = "netug2022live",

    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName = "test",

    [Parameter(Mandatory = $false)]
    [string]$Location = "australiaeast"
)

Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name $ResourceGroup --location $Location

Write-Host
Write-Host "📦 - Deploying Fullstack WebApp (from private registry)" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --name 'deploy-webapp-netug2022-live' `
    --resource-group $ResourceGroup `
    --template-file webapp-orchestrator.bicep `
    --parameters projectName="$($ProjectName)" environmentName="$($EnvironmentName)" `
    --verbose `
    --query properties.outputs `
    --output yaml

Write-Host
Write-Host "✅ - Done" -ForegroundColor Green