Function Get-SCCMFolderDetail
{
 <#
    .SYNOPSIS
    Returns the folder details that includes the container ID needed for other functions.
    .DESCRIPTION
    Connects to the specified site server and retrieves the details of the specified folder as output that in term can be used for other functions.
    By default the Device Folder type is specified unless overridden using the FolderType parameter, you can specify the following folder types:
    Type     2  : Package
    Type     3  : Advertisement
    Type     9  : Software Metering
    Type    18  : OS Images
    Type    19  : Boot Images
    Type    20  : Task Sequences
    Type    23  : Drivers
    Type  2011  : Configuration Baselines
    Type  5000  : Device Collection
    Type  5001  : User Collection
    Type  6000  : Application
    Type  6001  : Configuration Items
     
    .EXAMPLE
    Get-SCCMFolderDetail -FolderName "Maintenance Collections"
    .EXAMPLE
    Get-SCCMFolderDetail -FolderName "Maintenance Collections" -SiteServer mysiteserver.example.com
     
   .PARAMETER FolderName
    The FolderName parameter is the name of the folder for which you want to gather the details.
    .PARAMETER SiteServer
    The SiteServer parameter contains the name of the site server that can provide the folder details.
    .PARAMETER FolderType
    The FolderType parameter is optional and set to Device Folder by default unless specified (see description)
    .PARAMETER SiteCode
    The SiteCode parameter is optional and if not provided automatically retrieved from the specified site server.
     
  #>
  Param
  (
    [Parameter(Mandatory=$true)]
    [string]$FolderName,
    [Parameter(Mandatory=$true)]
    [string]$SiteServer,
    [Parameter(Mandatory=$false)]
    [string]$FolderType = "5000", # This is the device collection folder type
    [Parameter(Mandatory=$false)]
    [string]$SiteCode = (Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName $SiteServer).SiteCode
  )
  Begin
  {
    Write-Verbose "SCCM Site Server                   : $($SiteServer)"
    Write-Verbose "SCCM Site Code                     : $($SiteCode)"
    Write-Verbose "SCCM Folder Name                   : $($FolderName)"
    Write-Verbose "SCCM Folder Type                   : $($FolderType)"
  }
  Process
  {
    $FolderDetails = Get-wmiObject -Namespace "root\SMS\site_$($SiteCode)" -Query "Select name,containernodeid,objecttype,objecttypename from SMS_ObjectContainerNode where name = '$($FolderName)' AND objecttype = '$($FolderType)'" -ComputerName $SiteServer
  }
  End
  {
    return $FolderDetails
  }
}

Get-SCCMFolderDetail -FolderName "Remediation Collection" -SiteServer LLB-SCCM12PRI01.LLBEAN.COM
