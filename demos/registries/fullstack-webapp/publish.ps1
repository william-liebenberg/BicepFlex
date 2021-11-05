Get-ChildItem -Filter *.bicep | Foreach-Object {
    Write-Host "⬆️ - Publishing module: $($_.Basename)" -ForegroundColor Yellow

    # have to use bicep.exe directly on the current version - ensure that ~/.azure/bicep is in your PATH
    bicep publish $_.Fullname --target "br:bicepflex.azurecr.io/bicep/modules/$($_.Basename.ToLower()):v1.2"
}