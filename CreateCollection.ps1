Function Get-SCCMCollectionsInFolder
{
  <#
    .SYNOPSIS
    Returns all the collections located in the specified folder ID.
    .DESCRIPTION
    Connects to the specified site server and retrieves the details of the specified folder as output that in term can be used for other functions.
    This function is usable for Device or User collections any other items will need different WMI queries and these would be best added to a seperate function.
   
    .EXAMPLE
    Get-SCCMCollectionsInFolder -FolderID <id of your folder>
 
    .EXAMPLE
    Get-SCCMCollectionsInFolder -FolderID <id of your folder> -SiteServer mysiteserver.example.com
 
    .PARAMETER FolderID
    This parameter is the folder ID (can be gathered using a different function Get-SCCMFolderDetail)
    .PARAMETER FolderType
    The FolderType parameter is used to specify the folder type (5000 for Device Collections or 5001 for User Collections)
    .PARAMETER SiteServer
    The SiteServer parameter contains the name of the site server that can provide the collections contained below.
    .PARAMETER SiteCode
    The SiteCode parameter is optional and if not provided automatically retrieved from the specified site server.
    .PARAMETER Full
    This is an optional and determines that all collection fields need to be gathered from the site server this will include member count etc.
  #>
  Param
  (
    [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
    [string]$FolderID, 
    [Parameter(Mandatory=$False)]
    [string]$FolderType = "5000",
    [Parameter(Mandatory=$False)]
    [string]$SiteServer = "mysiteserver.example.com",
    [Parameter(Mandatory=$false)]
    [string]$SiteCode = (Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName $SiteServer).SiteCode,
    [Parameter(Mandatory=$False)]
    [switch]$Full = $false
  )
  Begin
  {
    Write-Verbose "SCCM Site Server                   : $($SiteServer)" 
    Write-Verbose "SCCM Site code                     : $($SiteCode)"
    Write-Verbose "SCCM Folder ID                     : $($FolderID)"
  }
  Process
  {
    Switch ($FolderType)
    {
      "5000" {$SCCMCollectionType = "2"}
      "5001" {$SCCMCollectionType = "1"}
      default {$SCCMCollectionType = "2"}
    }
    Write-Verbose "SCCM Collection Type               : $($SCCMCollectionType)"
    $FolderDetails = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Query "Select * from SMS_ObjectContainerNode where`
    ContainerNodeID='$($FolderID)'" -ComputerName $SiteServer
    If ($Full)
    {
      Write-Verbose $FolderDetails
    }
    Else
    {
      Write-Verbose "SCCM Folder Name                   : $($FolderDetails.Name)"
    }
    $SCCMCollectionQuery ="select Name,CollectionID from SMS_Collection where CollectionID is in(select InstanceKey from SMS_ObjectContainerItem `
    where ObjectType='$($FolderType)' and ContainerNodeID='$FolderID') and CollectionType='$($SCCMCollectionType)'"
    If ($Full)
    {
      $SCCMCollectionQuery ="select * from SMS_Collection where CollectionID is in(select InstanceKey from SMS_ObjectContainerItem`
      where ObjectType='$($FolderType)' and ContainerNodeID='$FolderID') and CollectionType='$($SCCMCollectionType)'" 
    }
    $CollectionsInSpecficFolder = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Query $SCCMCollectionQuery -ComputerName $SiteServer
    If ($VerbosePreference -eq "continue")
    {
      ForEach ($Collection in $CollectionsInSpecficFolder)
      {
        Write-Verbose "SCCM Collection Name               : $($Collection.name)"
        Write-verbose $Collection
      }
    }
  }
  End
  {
    return $CollectionsInSpecficFolder
  }
}

$collectionlist =  Get-SCCMCollectionsInFolder -FolderID 16778635 -SiteServer LLB-SCCM12PRI01.LLBEAN.COM | select name | Where-Object {$_.name -like "*remediation item*"}
$collectionlist 

$details = import-csv C:\temp\Detail_List.csv

#$detailgroups = $details | Group-Object -property plugin | Where-Object {$_.count -le 9}  | Select-Object group 
$detailgroups = $details | Where-Object {$_."plugin name" -like "*dreamweaver*"} | Select-Object *
#$vulnerabilities = $detailgroups | Select-Object * 
#$vulnerabilitiesgroup = $vulnerabilities | Group-Object -property "plugin name"
$vulnerabilitiesgroup = $detailgroups | Group-Object -property "plugin name"

foreach ($item in $vulnerabilitiesgroup){

    $pluginid = $item.group.plugin | Select -first 1
    $pluginname = $item.name.substring(0, [system.math]::Min(90, $item.name.Length))
    $collectionname = "Remediation Item $pluginid $pluginname"

    New-CMDeviceCollection -name $collectionname -LimitingCollectionName "All Desktops (Active - Not HomeAgentl)"
    $collection = Get-CMCollection -Name "Remediation Item $pluginid $pluginname"
    Move-CMObject -FolderPath 'LL1:\DeviceCollection\Remediation Collection' -InputObject $collection

}

#Get-CMCollection -Name $collectionname.name | Remove-CMCollection -Force
#============
$vulnerability = @()

foreach ($item in $vulnerabilitiesgroup.group){

    $pluginname = $item."plugin name"
    $hostname = $item.hostname
    $solution = $item.Solution
    $pluginid = $item.Plugin

    #Add-CMDeviceCollectionDirectMembershipRule -CollectionName "Remediation Item $pluginid $pluginname" -ResourceID (Get-CMDevice -Name $_).ResourceID 

}


#Get-CMCollection -CollectionType Device - | Select name # Where-Object {$_.name -like "*remediation*"}
#get-childitem 'LL1:\DeviceCollection' #\Remediation Collection' | select *