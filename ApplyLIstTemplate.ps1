# Define the target site URL
$targetSiteUrl = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit/Washington/Public"
$templateFilePath = "C:\Temp\HHHHMasterTasksNew.xml"

# Function to connect to SharePoint Online
function Connect-ToSharePointOnline {
    param (
        [string]$siteUrl
    )
    Connect-PnPOnline -Url $siteUrl -UseWebLogin
    Write-Output "Connected to SharePoint Online site $siteUrl"
}

# Function to apply the list schema with columns
function Apply-ListSchema {
    param (
        [string]$siteUrl,
        [string]$filePath
    )
    try {
        Connect-ToSharePointOnline -siteUrl $siteUrl

        Write-Output "Applying provisioning template from $filePath to site $siteUrl"
        
        # Apply the provisioning template with verbose logging
        Apply-PnPProvisioningTemplate -Path $filePath -Verbose
        
        Write-Output "List schema including columns has been successfully applied to the target site $siteUrl"
    }
    catch {
        Write-Output "An error occurred: $_"
    }
}

# Apply the list schema to the target site
Apply-ListSchema -siteUrl $targetSiteUrl -filePath $templateFilePath
