# Connect to SharePoint Online
$siteUrl = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit/washington/public"
Connect-PnPOnline -Url $siteUrl -UseWebLogin

# Define the source list title
#replace with your List Name
$sourceListTitle = "Announcements"
$templateFilePath = "C:\Temp\PublicAnnouncements.xml"

# Export the list as a template
Get-PnPProvisioningTemplate -Out $templateFilePath -Handlers Lists -ListsToExtract $sourceListTitle

Write-Output "List template has been exported to $templateFilePath"

# Import the list template to create a new list
$newListTitle = "NewListFromTemplate"
Apply-PnPProvisioningTemplate -Path $templateFilePath -Parameters @{
    "ListInstance_Lists_DisplayName" = $newListTitle
}

Write-Output "New list '$newListTitle' has been created from the template."
