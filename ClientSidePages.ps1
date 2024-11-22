
$sourceSiteUrl = "https://grueneweltweit.sharepoint.com/sites/GrueneWeltweit/washington/CMS"
Connect-PnPOnline -Url $sourceSiteUrl -UseWebLogin

# Get all client-side pages
$pages = Get-PnPListItem -List "SitePages"

# Set the export path
$exportPath = "C:\Temp\GrueneWeltweitPagesCMS.xml"

# Ensure the export directory exists
if (!(Test-Path -Path $exportPath)) {
    New-Item -ItemType Directory -Path $exportPath
}

# Loop through each page and export it
   foreach ($page in $pages) {
        $pageName = $page.FieldValues.FileLeafRef
        $outputPath = Join-Path -Path $exportPath -ChildPath "$pageName.xml"
        Export-PnPClientSidePage -Identity $pageName -Out $outputPath
        Write-Host "Exported $pageName to $outputPath"
    }