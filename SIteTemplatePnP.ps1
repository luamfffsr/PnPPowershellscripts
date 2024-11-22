# Install PnP PowerShell Module if not already installed
# Install-Module -Name "PnP.PowerShell"

# Connect to SharePoint Online
$sourceSiteUrl = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit/washington/public"
Connect-PnPOnline -Url $sourceSiteUrl -UseWebLogin

# Define the template file path
$templateFilePath = "C:\Temp\GruenePublicSiteTemplateUpdated.xml"

# Export the full site template
Get-PnPProvisioningTemplate -Out $templateFilePath -Handlers Lists, Fields, ContentTypes, Files, Pages

Write-Output "Site template has been exported to $templateFilePath"
