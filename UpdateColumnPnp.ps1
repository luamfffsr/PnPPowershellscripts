$SiteURL="https://hhhhteams.sharepoint.com/sites/HHHH/SP"
$ListName= "HHHH"
#$itemId = 16567;

#Connect-PnPOnline -Url $SiteURL -Credentials (Get-Credential)

Connect-PnPOnline -Url $SiteURL -UseWebLogin

#Disable Versioning
#Set-PnPTenantSite -DisableFlows $false
Set-PnPList -Identity $ListName -EnableVersioning $false

Start-Sleep -Seconds 9

$MasterItems = Get-PnPListItem -List "Master Tasks" -Fields "Title","ID","PortfolioStructureID";;
#foreach($ListItem in $MasterItems)
#{  
 #   Write-Host "Title:" $ListItem["Title"] "------------" "StructureID:" $ListItem["PortfolioStructureID"]
#}


Start-Sleep -Seconds 20;
 #$Listitem = Get-PnPListItem -List $ListName -ID $itemId -Fields "Title","ID","Portfolio" -PageSize 2000;

  $Listitem = Get-PnPListItem -List $ListName -Fields "Title","ID","Portfolio","TaskID","ParentTask","TaskType" -PageSize 2000;

 Write-host "Total Number of List Items:" $($Listitem.Count)

$lookupFieldName = "Portfolio";
#$lookupFieldValues = $ListItem[$lookupFieldName];
foreach($item in $Listitem)
{  
$lookupFieldValues = $item[$lookupFieldName];
if ($lookupFieldValues -ne $null) {
     $item["PortId"] = $lookupFieldValues.LookupId;
   # Write-Host "Component:" $item["PortId"] "------------" "Title:" $item["ID"]
}
};

$filteredItems = $Listitem | Where-Object { $_["ID"] -eq 16629 -or $_["ID"] -eq 16628 -or $_["ID"] -eq 16626 }

 foreach ($listval in $filteredItems) {
  # if($listval["ID"] -eq 16567 -or $listval["ID"] -eq 16569 -or $listval["ID"] -eq 16568){
  Write-Host "first Component:" $listval["PortId"] "------------" "Title:" $listval["ID"]
    foreach ($Masitem in $MasterItems) {
   if($listval["PortId"] -eq $Masitem["ID"]){
    $listval["MatchID"] = $true;
     $listval["StructureID"]=$Masitem["PortfolioStructureID"];
   Write-Host "Sec Component:" $Masitem["PortfolioStructureID"] "------------" "listval:" $listval["ID"];

     }
    }
 # }

 };
    
  $SmartMetadtafound = $filteredItems | Where-Object { $_["MatchID"] -eq $true };

function SampleFunction {
    param($item)

    $taskIds = ""
    $Portfolio = $item["StructureID"]
    $TaskID = $item["TaskID"]
    $ParentTask = $item["ParentTask"]
    $Id = $item["ID"]
    $TaskType = $item["TaskType"]
   # $TaskType = $TaskType[$lookupFieldName];

    if ($Portfolio -ne $null) {
        $taskIds += $Portfolio
    }

    if (($TaskType -ne $null -and $TaskType.LookupValue -eq 'Activities') -or ($TaskType -ne $null -and $TaskType.LookupValue -eq 'Workstream')) {
        if ($taskIds -ne $null -and $taskIds -ne '') {
            $taskIds += "-$TaskID"
        } else {
            $taskIds += $TaskID
        }
    }

    if ($ParentTask -ne $null -and $TaskType -ne $null -and $TaskType.LookupValue -eq 'Task') {
        if ($ParentTask.LookupId -ne $null) {
        $getParent = $Listitem | Where-Object { $_["ID"] -eq $ParentTask.LookupId };
         $getTaskID = $getParent["TaskID"];
            if ($taskIds -ne $null -and $taskIds -ne '') {
                $taskIds += "-$($getTaskID)-T$Id"
            } else {
                $taskIds += "$($getTaskID)-T$Id"
            }
        } 
        else {
            if ($taskIds -ne $null -and $taskIds -ne '') {
                $taskIds += "-T$Id"
            } else {
                $taskIds += "T$Id"
            }
        }
    } 
    elseif (($ParentTask -eq $null -or $ParentTask -eq '')  -and ($TaskType -ne $null -and $TaskType.LookupValue -eq 'Task')) {
        if ($taskIds -ne $null -and $taskIds -ne '') {
            $taskIds += "-T$Id"
        } else {
            $taskIds += "T$Id"
        }
    } 
    elseif ($taskIds -eq $null -or $taskIds -eq '') {
        $taskIds += "T$Id"
    }

    return New-Object PSObject -Property @{
        "NewGenerateTaskIds" = $taskIds;
        "StructureID" = $item["StructureID"];
         "ItemID" = $item["ID"];
    }
}

$processedItems = foreach ($val in $SmartMetadtafound) {
    SampleFunction -item $val
}

foreach ($processedItem in $processedItems) {
    Write-Host "TaskIds:" $processedItem.NewGenerateTaskIds "FilterComponent:" $processedItem.StructureID "-------------" "ItemId:" $processedItem.ItemID;
      Set-PnPListItem -List $ListName -Identity $processedItem.ItemID -Values @{"CompleteStructureID" = $processedItem.NewGenerateTaskIds} -SystemUpdate
}


#if ($ListItem[$lookupFieldName] -ne $null) {
    # Get the lookup field value
  #  $lookupFieldValue = $ListItem[$lookupFieldName]

    # Output the properties of the lookup field value
  #  Write-Host "Lookup Field Value Properties:"
  #  foreach ($property in $lookupFieldValue.PSObject.Properties) {
  #      Write-Host "Property Name: $($property.Name), Property Value: $($property.Value)"
 #   }
#} else {
   # Write-Host "Lookup field is null or empty for the list item."
#}



 
# Loop through each multilookup value
#foreach ($lookupValue in $lookupFieldValues) {
  #  Write-Host  "Component:" $lookupValue.LookupValue
#}
 
#Loop through each Item
#foreach($ListItem in $ListItems)
#{  
  #  Write-Host "Title:" $Listitem["Title"] "--------" "Id:" $Listitem["ID"] "---------" "TaskID:" $Listitem["TaskID"] "------------"   "Component:" $Listitem[$lookupFieldName]
#}

# Update the column values  TaskID


#$Listitem["CompleteStructureID"] = $ListItems["TaskID"]
#$UpdatedValues = @{
    #"CompleteStructureID" = $ListItem["TaskID"]
#}


# Update the item in the list
#Set-PnPListItem -List $ListName -Identity $itemId -Values $UpdatedValues -SystemUpdate



# Re-enable versioning
#Start-Sleep -Seconds 12
#Set-PnPList -Identity $ListName -EnableVersioning $true