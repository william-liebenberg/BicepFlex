param (
	[Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName = "dev",

    [Parameter(Mandatory = $false)]
    [string]$Location = "australiaeast"
)

Write-Host
Write-Host "🔨 - Creating Resource Group" -ForegroundColor Yellow
Write-Host
az group create --name $ResourceGroup --location $Location

Write-Host
Write-Host "🔨 - Deploying BicepFlex Fullstack WebApp (from private registry)" -ForegroundColor Yellow
Write-Host
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file webapp-orchestrator.bicep `
    --parameters projectName="$($ProjectName)" environmentName="$($EnvironmentName)" `
    --verbose `
    --query properties.outputs `
    --output yaml

Write-Host
Write-Host "✔️ - Done" -ForegroundColor Green