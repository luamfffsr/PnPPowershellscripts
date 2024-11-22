$SiteURL = "https://hhhhteams.sharepoint.com/sites/HHHH/SP"
$DocumentsListName = "Documents"
$LookupFieldName = "HHHH"
$HHHHListName = "HHHH"
$OutputFilePath = "C:\Users\HARSH\Documents\DocumentCollection.xlsx"

# Connect to SharePoint Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin

# Get all documents from the "Documents" list
$DocumentsListItems = Get-PnPListItem -List $DocumentsListName
$DocumentCollection | Export-Csv -Path $OutputFilePath -NoTypeInformation

# Array to store the collection of objects
$DocumentCollection = @()

# Check if any items were found
if ($DocumentsListItems.Count -eq 0) {
    # Write-Host "No items found in the 'Documents' list."
}
else {
    # Iterate through each document in the "Documents" list
    foreach ($Document in $DocumentsListItems) {
        # Create an object to store document details and corresponding HHHH list items
        $DocumentObject = New-Object PSObject -Property @{
            DocumentId = $Document.Id
            FileName = $Document["FileLeafRef"]
            LookupFieldValues = @()
        }

        # Get the Lookup Field value
        $LookupFieldValue = $Document[$LookupFieldName]

        # Check if the Lookup Field has values
        if ($LookupFieldValue) {
            # Assuming $LookupFieldValue contains a FieldLookupValue object
            $LookupIdArray = $LookupFieldValue | ForEach-Object { $_.LookupId }
            $LookupValueArray = $LookupFieldValue | ForEach-Object { $_.LookupValue }

            # Output Lookup Field values
            for ($i = 0; $i -lt $LookupIdArray.Count; $i++) {
                # Write-Host "Lookup Field '$LookupFieldName' - ID: $($LookupIdArray[$i]), Value: $($LookupValueArray[$i])"

                # Load items from the "HHHH" list based on the current Lookup ID and TaskType value
                $HHHHListItems = Get-PnPListItem -List $HHHHListName -Query "<View><Query><Where><And><Eq><FieldRef Name='ID' /><Value Type='Counter'>$($LookupIdArray[$i])</Value></Eq><Eq><FieldRef Name='TaskType' /><Value Type='Text'>Activities</Value></Eq></And></Where></Query></View>"

                # Check if any items were found in the "HHHH" list
                if ($HHHHListItems.Count -eq 0) {
                    # Write-Host "No 'Activities' found in the 'HHHH' list with ID '$($LookupIdArray[$i])'."
                }
                else {
                    # Output details of items in the "HHHH" list with TaskType 'Activities'
                    foreach ($HHHHItem in $HHHHListItems) {
                        # Write-Host "HHHH List Item ID: $($HHHHItem.Id)"

                        # Assuming $Project is the field name
                        $LookupFieldValueProject = $HHHHItem['Project']

                        if ($LookupFieldValueProject -ne $null) {
                            $LookupProjectID = $LookupFieldValueProject.LookupId
                            $LookupProjectValue = $LookupFieldValueProject.LookupValue

                            # Write-Host "Project Field - ID: $LookupProjectID, Value: $LookupProjectValue"

                            # Add the HHHH list item details to the LookupFieldValues property of the document object
                            $DocumentObject.LookupFieldValues += @{
                                HHHHListItemId = $HHHHItem.Id
                                ProjectId = $LookupProjectID
                                ProjectValue = $LookupProjectValue
                            }
                        }
                        else {
                            # Write-Host "Project field has no values for this HHHH list item."
                        }

                        # Add more properties as needed
                        # Write-Host "------------------------"
                    }
                }
            }
        }
        else {
            # Write-Host "Lookup field '$LookupFieldName' has no values for this document."
        }

        # Add the document object to the collection
        $DocumentCollection += $DocumentObject
    }
}

# Display the document collection
$DocumentCollection | Format-Table -AutoSize

# Disconnect from SharePoint Online
Disconnect-PnPOnline
