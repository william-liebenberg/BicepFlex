param(
    [Parameter(Mandatory=$true)]
    [string]$RegistryName,
    [Parameter(Mandatory=$true)]
    [string]$Tag
)

Get-ChildItem -Filter *.bicep | Foreach-Object {
    Write-Host "⬆️ - Publishing module: $($_.Basename)" -ForegroundColor Yellow

    # for now (v0.4.1008) - we have to use bicep.exe directly on the current version - ensure that ~/.azure/bicep is in your PATH
    bicep publish $_.Fullname --target "br:$($RegistryName).azurecr.io/bicep/modules/$($_.Basename.ToLower()):$($Tag)"
}