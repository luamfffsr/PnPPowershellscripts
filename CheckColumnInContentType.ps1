# Specify the site URL
$siteUrl = "https://ilftransactionhub.sharepoint.com/sites/ILF"

# Connect to the site
Connect-PnPOnline -Url $siteUrl -UseWebLogin

# Variable
$siteColumnName = "SharewebTaskLevel2No"  # Internal name of the site column

# Get all content types in the site
$contentTypes = Get-PnPContentType

# Loop through each content type and remove the site column if it exists
foreach ($contentType in $contentTypes) {
    $fields = Get-PnPField -ContentType $contentType
    foreach ($field in $fields) {
        if ($field.InternalName -eq $siteColumnName) {
            Write-Output "Removing site column '$siteColumnName' from content type: $($contentType.Name)"
            Remove-PnPFieldFromContentType -Field $siteColumnName -ContentType $contentType
        }
    }
}

# Delete the site column from the site
Remove-PnPField -Identity $siteColumnName -Force
Write-Output "Site column '$siteColumnName' deleted from the site."
