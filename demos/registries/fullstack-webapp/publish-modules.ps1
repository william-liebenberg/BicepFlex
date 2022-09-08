param(
    [Parameter(Mandatory=$true)]
    [string]$RegistryName="acrnetug2022",
    [Parameter(Mandatory=$true)]
    [string]$Tag
)

Get-ChildItem -Filter *.bicep | Foreach-Object {
    Write-Host "⬆️ - Publishing module: $($_.Basename)" -ForegroundColor Yellow
    az bicep publish -f $_.Fullname --target "br:$($RegistryName).azurecr.io/bicep/modules/$($_.Basename.ToLower()):$($Tag)"
}