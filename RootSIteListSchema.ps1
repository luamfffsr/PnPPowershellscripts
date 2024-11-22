# Install PnP PowerShell Module if not already installed
# Install-Module -Name "PnP.PowerShell"

# Define the source site URL and list title
$sourceSiteUrl = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit"
$sourceListTitle = "SmartMetadata"
$templateFilePath = "C:\Temp\GrueneWeltweitSmartMetadata.xml"

# Function to connect to SharePoint Online
function Connect-ToSharePointOnline {
    param (
        [string]$siteUrl
    )
    Connect-PnPOnline -Url $siteUrl -UseWebLogin
}

# Function to export the list schema with columns
function Export-ListSchema {
    param (
        [string]$siteUrl,
        [string]$listTitle,
        [string]$filePath
    )
    Connect-ToSharePointOnline -siteUrl $siteUrl
    Get-PnPProvisioningTemplate -Out $filePath -Handlers Lists -ListsToExtract $listTitle
    Write-Output "List schema including columns has been exported to $filePath"
}

# Export the list schema from the source site
Export-ListSchema -siteUrl $sourceSiteUrl -listTitle $sourceListTitle -filePath $templateFilePath