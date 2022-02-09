﻿#get-cmuser -name LLBEAN\jimenez1  | select name #, smsid
#get-aduser gwestergre
$TenHosts = import-csv -Path C:\temp\java.csv
#$TenHosts = Get-CMCollection -Name "~Software Updates - All targeted desktops" | Get-CMCollectionMember | Select-Object Name

$sccmdevicelists = @()
$c1 = 0

Foreach ($tenhost in $TenHosts){
$c1++
Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($TenHosts.count)" -CurrentOperation $tenhost.name -PercentComplete (($c1/$TenHosts.Count) * 100)
$sccmdevicelist = get-cmdevice -name $tenhost.name | Select-Object *, @{Name = 'User'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}},`
@{Name = 'PingStatus'; Expression = {(Test-Connection -ComputerName $tenhost.name -Quiet -Count 1 -ErrorAction SilentlyContinue)}}

if ($sccmdevicelist -ne $null){
$sccmdevicelists += $sccmdevicelist
}
else {
    Write-Host -ForegroundColor Red $tenhost.name" not in SCCM"
    $myObject = [PSCustomObject]@{
        Name = $tenhost.name
        User = "not in SCCM"
    }
    $sccmdevicelist = $myObject | Select-Object name, user
    $sccmdevicelists += $sccmdevicelist
}

}
$date = get-date -Format "_MMddyy_HHmm"
$sccmdevicelists | export-csv -NoTypeInformation "c:\temp\java$date.csv"
#$sccmdevicelists | export-csv -NoTypeInformation "c:\temp\sccmdevicelist$date.csv"

#$file = "c:\temp\sccmdevicelist$date.csv"
$file = "c:\temp\java$date.csv"
$dest = "\\llb-pkg01\source\Remediation source\Reports\"
move-Item $file -Destination filesystem::$dest



#Foreach ($tenhost in $TenHosts){
#$c1++
#Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($TenHosts.count)" -CurrentOperation $tenhost.name -PercentComplete (($c1/$TenHosts.Count) * 100)
#$sccmdevicelist = get-cmdevice -name $tenhost.name | select Name, ADLastLogonTime, CNLastOfflineTime, CNLastOnlineTime, DeviceOS, DeviceOSBuild, IsActive, LastActiveTime, CNIsOnline, `
#LastClientCheckTime, LastLogonUser, UserName, @{Name = 'User'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}},`
#@{Name = 'PingStatus'; Expression = {(Test-Connection -ComputerName $tenhost.name -Quiet -Count 1 -ErrorAction SilentlyContinue)}}
#$sccmdevicelists += $sccmdevicelist
#}


#$sccmdevicelists = @()
#Foreach ($tenhost in $TenHosts){
#$sccmdevicelist = get-cmdevice -name $tenhost.name | select Name, ADLastLogonTime, CNLastOfflineTime, CNLastOnlineTime, DeviceOS, DeviceOSBuild, IsActive, LastActiveTime,`
#LastClientCheckTime, LastLogonUser, UserName, @{Name = 'User'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}},`
#@{Name = 'PingStatus'; Expression = {(Test-Connection -ComputerName $tenhost.name -Quiet -Count 1 -ErrorAction SilentlyContinue)}}
#$sccmdevicelists += $sccmdevicelist
#}

