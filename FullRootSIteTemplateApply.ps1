# Define the target site URL
$targetSiteUrl = "https://hhhhteams.sharepoint.com/sites/ILF"

# Define the template file path
$templateFilePath = "C:\Temp\HHHHRootSiteTemplate.xml"

# Function to connect to SharePoint Online
function Connect-ToSharePointOnline {
    param (
        [string]$siteUrl
    )
    Connect-PnPOnline -Url $siteUrl -UseWebLogin
}

# Function to check if a field exists
function Check-FieldExists {
    param (
        [string]$fieldName
    )
    $field = Get-PnPField -Identity $fieldName -ErrorAction SilentlyContinue
    return $field -ne $null
}

# Function to check if a content type exists
function Check-ContentTypeExists {
    param (
        [string]$contentTypeName
    )
    $contentType = Get-PnPContentType -Identity $contentTypeName -ErrorAction SilentlyContinue
    return $contentType -ne $null
}

# Function to apply the site template
function Apply-SiteTemplate {
    param (
        [string]$siteUrl,
        [string]$filePath
    )
    Connect-ToSharePointOnline -siteUrl $siteUrl

    # Check for existing columns and content types
    try {
        # Apply the provisioning template
        Apply-PnPProvisioningTemplate -Path $filePath -Handlers ContentTypes, Fields -ErrorAction Stop
        Write-Output "Site template has been applied to the target site $siteUrl"
    } catch {
        Write-Output "An error occurred while applying the template: $_"
    }
}

# Apply the site template to the target site
Apply-SiteTemplate -siteUrl $targetSiteUrl -filePath $templateFilePath
