#get-cmuser -name LLBEAN\gwestergre  | select name #, smsid
#get-aduser gwestergre
$file = "bridge"
$TenHosts = import-csv -Path C:\temp\$file.csv
#$TenHosts = Get-CMCollection -Name "~Software Updates - All targeted desktops" | Get-CMCollectionMember | Select-Object Name

$sccmdevicelists = @()
$c1 = 0

Foreach ($tenhost in $TenHosts){
$c1++
Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($TenHosts.count)" -CurrentOperation $tenhost.name -PercentComplete (($c1/$TenHosts.Count) * 100)

$sccmdevicelist = get-cmdevice -name $tenhost.name | Select-Object Name, @{Name = 'PingStatus'; Expression = {(Test-Connection -ComputerName $tenhost.name -Quiet -Count 1 -ErrorAction SilentlyContinue)}},`
@{Name = 'ADUser'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}}, LastLogonUser, CurrentLogonUser,`
UserName, PrimaryUser, ADLastLogonTime, CNIsOnline, CNLastOfflineTime, CNLastOnlineTime, DeviceOS, DeviceOSBuild, IsActive, LastActiveTime, LastClientCheckTime,`
LastHardwareScan, LastPolicyRequest, LastSoftwareScan, LastStatusMessage, SerialNumber

if ($sccmdevicelist -ne $null){
$sccmdevicelists += $sccmdevicelist
}
else {
    Write-Host -ForegroundColor Red $tenhost.name" not in SCCM"
    $sccmdevicelist = [PSCustomObject]@{
        Name = $tenhost.name
        PingStatus = "not in SCCM"
    }
    
    $sccmdevicelists += $sccmdevicelist
}

}
$date = get-date -Format "_MMddyy_HHmm"
$sccmdevicelists | export-csv -NoTypeInformation "c:\temp\$file$date.csv"

#$file = "c:\temp\$file$date.csv"
#$dest = "\\llb-pkg01\source\Remediation source\Reports\"
#move-Item $file -Destination filesystem::$dest



#@{Name='LastBootUpTime';Expression={(Get-WmiObject win32_operatingsystem -computername $tenhost.name | select $_.ConverttoDateTime($_.lastbootuptime))}},`