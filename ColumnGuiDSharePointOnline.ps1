# Prompt user for input
$SiteURL = Read-Host "Enter the SharePoint site URL (e.g., https://yourtenant.sharepoint.com/sites/YourSite)"
$ListName = Read-Host "Enter the name of the SharePoint list"

# Connect to SharePoint Online using PnP PowerShell
Connect-PnPOnline -Url $SiteURL -UseWebLogin

# Get the SharePoint list
$List = Get-PnPList -Identity $ListName
if ($null -eq $List) {
    Write-Host "List '$ListName' not found."
}
else {
    # Get all fields (columns) from the list
    $Fields = Get-PnPField -List $ListName | Select-Object Title, InternalName, Id

    # Output the columns with their GUIDs and FieldRefs
    $Fields | ForEach-Object {
        $FieldRef = "<FieldRef Name='$($_.InternalName)' />"
        [PSCustomObject]@{
            Title = $_.Title
            InternalName = $_.InternalName
            Id = $_.Id
            FieldRef = $FieldRef
        }
    } | Format-Table -AutoSize
}
