# Create a Service Principal with Contributor role on the Subscription that can create resource groups and resources on the entire subscription
# This is not best practice since the SP has too much power
# Instead, limit the scope to the specific resource group or even individual resources
#
# Also, this script requires the GitHub CLI to be installed so that we can set the AZURE_CREDENTIALS secret directly after creating the SP

$subscriptionId =  az account show --query 'id' -o tsv

$servicePrincipal = az ad sp create-for-rbac `
	--name "BicepFlex-GHActions" `
	--role contributor `
	--scopes /subscriptions/$subscriptionId

gh secret set AZURE_CREDENTIALS -b "$servicePrincipal"