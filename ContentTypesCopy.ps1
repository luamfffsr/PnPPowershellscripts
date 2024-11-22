# Define the site URL and the output folder path
$siteUrl = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit"
$templatesFolderPath = "C:\Templates"

# Check if the Templates folder exists, if not, create it
if (-not (Test-Path -Path $templatesFolderPath)) {
    New-Item -ItemType Directory -Path $templatesFolderPath
}

# Define the output file path for the template
$outputPath = "C:\Templates\site-templateGrueneWeltweitRoot.xml"

# Disable legacy messages in the current session
$env:PNPLEGACYMESSAGE='false'

# Connect to SharePoint Online site
Connect-PnPOnline -Url $siteUrl -UseWebLogin -WarningAction Ignore

# Extract the template including Security, SiteFields, ContentType, Lists, and Features
Get-PnPProvisioningTemplate `
    -Out $outputPath `
    -Handlers Lists, ContentTypes, Fields, SiteSecurity, Features `
    -IncludeSiteCollectionTermGroup `
    -PersistBrandingFiles

# Disconnect from the site
Disconnect-PnPOnline

Write-Host "The template has been saved at $outputPath"