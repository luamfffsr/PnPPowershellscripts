$SiteURL = "https://hhhhteams.sharepoint.com/sites/HHHH/SP"
$DocumentsListName = "Documents"

# Define additional lookup fields and their corresponding list names
$LookupFieldMappings = @{
    "HHHH"        = "HHHH"
    "EI"          = "EI"
    "EPS"         = "EPS"
    "Education"   = "Education"
    "DRR"         = "DRR"
    "Gender"      = "Gender"
    "Gruene"      = "Gruene"
    "Health"      = "Health"
    "QA"          = "QA"
    "Shareweb"    = "Shareweb"
    "DE"          = "DE"
    "Migration"   = "Migration"
    "ALAKDigital" = "ALAKDigital"
    "KathaBeck"   = "KathaBeck"
}

# Connect to SharePoint Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin

# Array to store the collection of objects
$DocumentCollection = @()

# Get all documents from the "Documents" list
$DocumentsListItems = Get-PnPListItem -List $DocumentsListName 

# Check if any items were found
if ($DocumentsListItems.Count -eq 0) {
    # Write-Host "No items found in the 'Documents' list."
}
else {
    # Iterate through each document in the "Documents" list
    foreach ($Document in $DocumentsListItems) {
        # Create an object to store document details and corresponding list items
        $DocumentObject = New-Object PSObject -Property @{
            DocumentId        = $Document.Id
            FileName          = $Document["FileLeafRef"]
            PortfolioItem     = $Document.FieldValues["Portfolios"].LookupId
            LookupFieldValues = @{}
        }

        # Flag to determine if the document should be added to the collection
        $AddToCollection = $false

        # Iterate through the specified lookup fields
        foreach ($LookupField in $LookupFieldMappings.Keys) {
            # Get the Lookup Field value
            $LookupFieldValue = $Document[$LookupField]

            # Check if the Lookup Field has values
            if ($LookupFieldValue) {
                # Assuming $LookupFieldValue contains a FieldLookupValue object
                $LookupIdArray = $LookupFieldValue | ForEach-Object { $_.LookupId }
                $LookupValueArray = $LookupFieldValue | ForEach-Object { $_.LookupValue }

                # Create an array to store lookup items
                $LookupItemsArray = @()

                # Output Lookup Field values
                for ($i = 0; $i -lt $LookupIdArray.Count; $i++) {
                    # Load items from the corresponding list based on the current Lookup ID
                    $ListName = $LookupFieldMappings[$LookupField]
                    $ListItems = Get-PnPListItem -List $ListName -Query "<View><Query><Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>$($LookupIdArray[$i])</Value></Eq></Where></Query></View>"

                    # Add the lookup item details to the array
                    $LookupItem = @{
                        ListItemId = $LookupIdArray[$i]
                        ListName   = $ListName
                        ListItems  = $ListItems
                    }
                    $LookupItemsArray += $LookupItem
                }

                # Add the lookup field details to the collection
                $DocumentObject.LookupFieldValues[$LookupField] = $LookupItemsArray

                # Set the flag to true if there are lookup items
                $AddToCollection = $true
            }
        }

        # Add the document object to the collection only if there are lookup items
        if ($AddToCollection) {
            $DocumentCollection += $DocumentObject
        }
    }
}

# Display the document collection
$DocumentCollection | Format-Table -AutoSize
# Set the batch size for updating documents
$BatchSize = 10

# Get the total number of documents to update
$TotalDocuments = $DocumentCollection.Count

# Initialize a counter for processed documents
$ProcessedDocuments = 0

# Iterate through each document object in the DocumentCollection
foreach ($DocumentObject in $DocumentCollection) {
    $DocumentId = $DocumentObject.DocumentId
    
    # Retrieve the existing values from the 'Portfolios' column of the document item
    $ListItem = Get-PnPListItem -List $DocumentsListName -Id $DocumentId
    $ExistingPortfolios = $ListItem.FieldValues.Portfolios
    
    # Convert existing values to an array if available
    if ($ExistingPortfolios) {
        $ExistingLookupIds = $ExistingPortfolios.LookupId
    }
    else {
        $ExistingLookupIds = @()
    }

    # Initialize an array to store new lookup IDs
    $NewLookupIds = @()
    
    $LookupFieldValues = $DocumentObject.LookupFieldValues
    
    # Iterate through each lookup field value and its corresponding list items
    foreach ($LookupField in $LookupFieldValues.Keys) {
        $LookupItemsArray = $LookupFieldValues[$LookupField]
        
        # Iterate through each lookup item
        foreach ($LookupItem in $LookupItemsArray) {
            $LookupId = $LookupItem.ListItems.FieldValues["Project"].LookupId
            
            # Add the new lookup ID to the array
            $NewLookupIds += $LookupId
        }
    }
    
    # Merge existing and new lookup IDs and remove duplicates
    $CombinedLookupIds = @($ExistingLookupIds) + @($NewLookupIds) | Select-Object -Unique
    
    # Update the 'Portfolios' column of the document item with the combined list of IDs
    Set-PnPListItem -List $DocumentsListName -Identity $DocumentId -Values @{ 'Portfolios' = $CombinedLookupIds } -SystemUpdate
    
    # Increment the counter for processed documents
    $ProcessedDocuments++
    
    # Check if the batch size limit is reached or all documents are processed
    if ($ProcessedDocuments % $BatchSize -eq 0 -or $ProcessedDocuments -eq $TotalDocuments) {
        Write-Host "Processed $ProcessedDocuments out of $TotalDocuments documents."
    }
}

# Disconnect from SharePoint Online
Disconnect-PnPOnline
