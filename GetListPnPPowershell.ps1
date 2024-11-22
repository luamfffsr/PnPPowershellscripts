$SiteURL = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit/washington/public"
$DocumentsListName = "Announcements"
$OutputFilePath = "C:\Users\HARSH\Documents\AnnouncementsPublic.csv"

# Connect to SharePoint Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin

# Get all documents from the "SmartMetadata" list
$DocumentsListItems = Get-PnPListItem -List $DocumentsListName

# Select only the "FieldValues" property of each item and export to CSV
$DocumentsListItems | Select-Object -Property FieldValues | Export-Csv -Path $OutputFilePath -NoTypeInformation

# Disconnect from SharePoint Online
Disconnect-PnPOnline