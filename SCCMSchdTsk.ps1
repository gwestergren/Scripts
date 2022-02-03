#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '1/10/2022 8:13:43 AM'.

# Site configuration
$SiteCode = "LL1" # Site code 
$ProviderMachineName = "LLB-SCCM12PRI01.LLBEAN.COM" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


$TenHosts = Get-CMCollection -Name "~Software Updates - All targeted desktops" | Get-CMCollectionMember | Select-Object Name

$sccmdevicelists = @()
$c1 = 0

Foreach ($tenhost in $TenHosts){
$c1++
Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($TenHosts.count)" -CurrentOperation $tenhost.name -PercentComplete (($c1/$TenHosts.Count) * 100)
$sccmdevicelist = get-cmdevice -name $tenhost.name | select *, @{Name = 'User'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}},`
@{Name = 'PingStatus'; Expression = {(Test-Connection -ComputerName $tenhost.name -Quiet -Count 1 -ErrorAction SilentlyContinue)}}
$sccmdevicelists += $sccmdevicelist
}
$date = get-date -Format "_MMddyy_HHmm"
$sccmdevicelists | export-csv -NoTypeInformation "c:\temp\sccmdevicelist$date.csv"

$file = "c:\temp\sccmdevicelist$date.csv"
$dest = "\\llb-pkg01\source\Remediation source\Reports\"
move-Item $file -Destination filesystem::$dest