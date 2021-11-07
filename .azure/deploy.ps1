Param(
	[Parameter(Mandatory = $false)]
	[String]$resourceGroup = "bicepflex",

	[Parameter(Mandatory = $false)]
	[String]$location = "australiaeast",

	[Parameter(Mandatory = $false)]
	[String]$bicepFile = "azureDeploy.bicep",

	[Parameter(Mandatory = $false)]
	[String]$bicepParametersFile = "parameters.json",

	[Parameter(Mandatory = $false)]
	[Switch]$dryRun
)

Write-Host "👀 Checking important files..."
if ($false -eq (Test-Path $bicepFile)) {
	Write-Host "❌ The BICEP file $($bicepFile) cannot be found!" -ForegroundColor Red
	exit 1;
}

if ($false -eq (Test-Path $bicepParametersFile)) {
	Write-Host "❌ The BICEP Parameters file $($bicepParametersFile) cannot be found!" -ForegroundColor Red
	exit 1;
}

# NOTE: You must have logged in via 'az login' before running this deployment
Write-Host "👀 Checking if your Azure access token is valid..."
$azureAccessTokenExpiration = az account get-access-token --query "expiresOn" --output tsv
if ($DebugPreference -ne "SilentlyContinue") {
	Write-Host $azureAccessTokenExpiration -ForegroundColor Magenta
}

try {
	# expiry date example = 2021-08-18 14:13:30.365912
	$dt = [datetime]::ParseExact($azureAccessTokenExpiration, 'yyyy-MM-dd HH:mm:ss.ffffff', $null)
	Write-Host "✨ Your Azure Access Token expires on: $($dt)" -ForegroundColor Cyan
}
catch {
	Write-Error "⚠️ Please login with az login"
	exit 1;
}

Write-Host "🔨 Creating Resource Group $($resourceGroup)" -ForegroundColor Yellow
az group create -l $location -n $resourceGroup

Write-Host "👀 Running What-If on your Bicep file..." -ForegroundColor Cyan
az deployment group what-if `
	-g $resourceGroup `
	--template-file $bicepFile `
	--parameters @$bicepParametersFile

if (!$?) {
	Write-Host
	Write-Host "❌ What-if failed... aborting!" -ForegroundColor Red
	exit 1
}
else {
	Write-Host
}

if (!$dryRun.IsPresent) {
	Write-Host "🔨 Deploying bicep" -ForegroundColor Yellow
	Write-Host

	$output = (az deployment group create `
			-g $resourceGroup `
			--template-file $bicepFile `
			--name "deployment-$($deploymentTimestamp)" `
			--mode Incremental `
			--parameters @$bicepParametersFile --query properties.outputs) 
    
	if ($DebugPreference -ne "SilentlyContinue") {
		Write-Host $output -ForegroundColor Cyan
	}

	if (!$?) {
		Write-Host "❌ Deploying Bicep failed... aborting!" -ForegroundColor Red
		exit 1
	}
}

Write-Host
Write-Host "✅ Completed" -ForegroundColor Green