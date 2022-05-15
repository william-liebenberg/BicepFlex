param(
    [Parameter(Mandatory=$true)]
    [string]$RegistryName,
    [Parameter(Mandatory=$true)]
    [string]$Tag
)

Get-ChildItem -Filter *.bicep | Foreach-Object {
    Write-Host "⬆️ - Publishing module: " -ForegroundColor Red -NoNewline
    Write-Host $_.Basename -ForegroundColor Green

    az bicep publish -f $_.Fullname --target "br:$($RegistryName).azurecr.io/bicep/modules/$($_.Basename.ToLower()):$($Tag)"
}