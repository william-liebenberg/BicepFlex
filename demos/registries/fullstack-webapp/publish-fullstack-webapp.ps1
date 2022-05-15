param(
    [Parameter(Mandatory=$true)]
    [string]$RegistryName,
    [Parameter(Mandatory=$true)]
    [string]$Tag
)

Write-Host "⬆️ - Publishing module: " -ForegroundColor Red -NoNewline
Write-Host "fullstack-webapp" -ForegroundColor Green

az bicep publish -f "fullstack-webapp.bicep" --target "br:$($RegistryName).azurecr.io/bicep/modules/fullstack-webapp:$($Tag)"