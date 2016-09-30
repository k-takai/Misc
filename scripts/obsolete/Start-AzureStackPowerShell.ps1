# For Azure Stack TP1 (PoC) Only.

# Add the Microsoft Azure Stack environment
$AadTenantId = "<Please input tenant id>"

if($AadTenantId -eq "<Please input tenant id>") {
    Write-Output "Please modify tenant id"
    exit
}

# Configure the environment with the Add-AzureRmEnvironment cmdlet
Add-AzureRmEnvironment -Name 'Azure Stack TP1' `
    -ActiveDirectoryEndpoint ("https://login.windows.net/$AadTenantId/") `
    -ActiveDirectoryServiceEndpointResourceId "https://azurestack.local-api/"`
    -ResourceManagerEndpoint ("https://api.azurestack.local/") `
    -GalleryEndpoint ("https://gallery.azurestack.local/") `
    -GraphEndpoint "https://graph.windows.net/"

# Authenticate a user to the environment (you will be prompted during authentication)
$privateEnv = Get-AzureRmEnvironment 'Azure Stack TP1'
$privateAzure = Add-AzureRmAccount -Environment $privateEnv -Verbose
Select-AzureRmProfile -Profile $privateAzure

# Select an existing subscription where the deployment will take place
Get-AzureRmSubscription -SubscriptionName "SUBSCRIPTION_NAME"  | Select-AzureRmSubscription
