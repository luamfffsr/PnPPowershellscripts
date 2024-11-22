OneDrive# Load the SharePoint Online PnP module
Import-Module SharePointPnPPowerShellOnline

# Variables for source and target sites and lists
$sourceSiteUrl = "https://hhhhteams.sharepoint.com/sites/GrueneWeltweit"
$sourceListName = "SmartMetadata"

$targetSiteUrl = "https://smalsusinfolabs.sharepoint.com/sites/HHHHQA"
$targetListName = "SmartMetadata"

# Connect to SharePoint Online - Source site
Connect-PnPOnline -Url $sourceSiteUrl -UseWebLogin

# Get list items from the source list
$listItems = Get-PnPListItem -List $sourceListName -PageSize 5000

# Connect to SharePoint Online - Target site
Connect-PnPOnline -Url $targetSiteUrl -UseWebLogin

# Get list columns from the target list (to ensure same structure)
$listColumns = Get-PnPField -List $targetListName | Where-Object { $_.Hidden -eq $false } | Select-Object InternalName, TypeAsString

# Function to convert value to appropriate type
function Convert-To-FieldValue {
    param(
        [string]$fieldType,
        [object]$value
    )
    switch -exact ($fieldType) {
        "Text" { return [string]$value }
        "Note" { return [string]$value }
        "DateTime" { return [datetime]$value }
        "Boolean" { return [bool]$value }
        "Number" { return [double]$value }
        default { return $value }
    }
}

# Copy items from source list to target list
foreach ($item in $listItems) {
    $itemProperties = @{}
    foreach ($column in $listColumns) {
        $fieldName = $column.InternalName
        $fieldType = $column.TypeAsString
        $value = $item[$fieldName]

        if ($null -ne $value) {
            $itemProperties.Add($fieldName, (Convert-To-FieldValue -fieldType $fieldType -value $value))
        }
    }

    try {
        Add-PnPListItem -List $targetListName -Values $itemProperties -ErrorAction Stop
        Write-Host "Item copied to $targetListName successfully."
    } catch {
        Write-Warning "Error copying item to $targetListName."
    }
}

Write-Host "Data copied from $sourceListName on $sourceSiteUrl to $targetListName on $targetSiteUrl successfully."

# Disconnect from SharePoint sites
Disconnect-PnPOnline
