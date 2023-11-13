[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Path
)

$arcCSV = Import-csv $Path

function Build-TagsObject($arcCSVObjects) {
   
    $tagNames = $arcCSVObjects | Get-Member | foreach-object { if($_.Name -like "Tag_*" ){ $_.Name } }

    $arcObjectTags = @()
    foreach($arcCSVObject in $arcCSVObjects){
        $tagHash = @{}
        $arcObjectTag = "" | Select Name,Type, ResourceGroup, Tags
        foreach($tagName in $tagNames){
            $tagNameTrimmed = $tagName.TrimStart("TAG").TrimStart("_")
            $tagValue = $arcCSVObject."$tagName"
            $tagHash.Add($tagNameTrimmed,$tagValue)
        }
        $arcObjectTag.Name = $arcCSVObject.Name
        $arcObjectTag.Type = $arcCSVObject.Type
        $arcObjectTag.ResourceGroup = $arcCSVObject.ResourceGroup
        $arcObjectTag.Tags = $tagHash
        $arcObjectTags += $arcObjectTag
    }
    
    return $arcObjectTags

   
}

function Tag-AzArc($arcObjectTags){


    $subscriptionId = (Get-AzContext).Subscription
    foreach($arcObjectTag in $arcObjectTags){
        $resourceGroup = $arcObjectTag.ResourceGroup
        $name = $arcObjectTag.Name
        if($arcObjectTag.Type -eq "VM"){

            $resourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.HybridCompute/machines/$name"
            $existingTag = [hashtable](Get-AzTag -ResourceId $resourceId).Properties.TagsProperty
            #New-AzTag -ResourceId  $resourceId -Tag ( Merge-Hashtables $arcObjectTag.Tags $existingTag ) -Verbose
            Update-AzTag -ResourceId  $resourceId -Tag $arcObjectTag.Tags -Operation Merge -Verbose



        }
        if($arcObjectTag.Type -eq "SQLINSTANCE"){
            $resourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.AzureArcData/SqlServerInstances/$name"
            $existingTag = [hashtable](Get-AzTag -ResourceId $resourceId).Properties.TagsProperty
            #New-AzTag -ResourceId  $resourceId -Tag ( Merge-Hashtables $arcObjectTag.Tags $existingTag ) -Verbose
            Update-AzTag -ResourceId  $resourceId -Tag  $arcObjectTag.Tags -Operation Merge -Verbose
            
        }

    }
}

Tag-AzArc -arcObjectTags (Build-TagsObject -arcCSVObjects $arcCSV)