#globals
$global:payloadcoll       = @()

$details = import-csv C:\temp\Detail_List.csv

$systemnames = @()
foreach ($name in $details){
$dnsname = ($name."dns name".Split(".")[0])
$netbiosname = ($name."netbios name".Split("\")[1])

    if ($netbiosname.Length -gt 1){
        $sccmdevicelist = [PSCustomObject]@{
        NetBiosname = $name."NetBios name"
        Name = "not in SCCM"
        }
        $systemnames += $netbiosname
        }
    else{
    
    
    
        $systemnames += $dnsname
        }
}
$systemnames

$pcname= Read-Host -Prompt "Enter System name"
#$pluginname= Read-Host -Prompt "Enter Plugin name"
#$systemnames.Contains("$pcname")
$details = import-csv C:\temp\Detail_List.csv
$details | Where-Object {$_."netbios name" -like "*$pcname*"} | sort plugin | select "Netbios Name", plugin, "Plugin Name", "last Observed" | export-csv -NoTypeInformation C:\temp\LPC0HEGSB-LP.csv


$Vulnerability_Name = Read-Host -Prompt "Enter Plugin name"
$details = import-csv C:\temp\Detail_List.csv

#$detailgroups = $details | Where-Object {$_."netbios name" -like "*$systemnames*"} | Select-Object * 
#$detailgroups = $details | Group-Object -property "NetBios Name" | Where-Object {$_.count -lt 2} | Select-Object group
$detailgroups = $details | Where-Object {$_."plugin name" -like "*$Vulnerability_Name*"} | Select-Object *
$vulnerabilities = $detailgroups | Select-Object * 
#$vulnerabilities = $detailgroups.group | Select-Object * 
$vulnerability = @()
$c1 = 0
#$hostname = @()
foreach ($item in $vulnerabilities){
    $c1++
    Write-Progress -Activity 'Checking systems' -Status "Processing $($c1) of $($vulnerabilities.count)" -CurrentOperation $item."NetBIOS Name" -PercentComplete (($c1/$vulnerabilities.Count) * 100)

    if (($item."netbios name").Length -gt 1) {$parts = $item | Select-Object *, @{Name = 'Hostname'; Expression = {$_."netbios name".Split('\')[1]}}

    $vulnerability += $parts  
    }
    elseif (($item."dns name").Length -gt 1) {$parts = $item | Select-Object *, @{Name = 'Hostname'; Expression = {$_."dns name".Split('.')[0]}}

    $vulnerability += $parts 
    }
}
#$vulnerability | export-csv -NoTypeInformation c:\temp\vul.csv
$c1 = 0
foreach ($item in $vulnerability){
    $c1++
    Write-Progress -Activity 'Sending emails' -Status "Processing $($c1) of $($vulnerability.count)" -CurrentOperation $item."NetBIOS Name" -PercentComplete (($c1/$vulnerability.Count) * 100)

    $sccmdevicelist = get-cmdevice -name $item.name | Select-Object Name, @{Name = 'PingStatus'; Expression = {(Test-Connection -ComputerName $item.name -Quiet -Count 1 -ErrorAction SilentlyContinue)}},`
    @{Name = 'ADUser'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}}, LastLogonUser, CurrentLogonUser, UserName, PrimaryUser, ADLastLogonTime, CNIsOnline, CNLastOfflineTime, CNLastOnlineTime,`
    DeviceOS, DeviceOSBuild, IsActive, LastActiveTime, LastClientCheckTime, LastHardwareScan, LastPolicyRequest, LastSoftwareScan, LastStatusMessage, SerialNumber

    $emailuser = $sccmdevicelist.LastLogonUser + "@llbean.com"
    $fullname = $sccmdevicelist.user
    $pluginname = $item."plugin name"
    $hostname = $item.hostname
#    $output = $item."plugin output"
#    $description = $item.description
    $solution = $item.Solution
    $pluginid = $item.Plugin
    #$ADUser = Get-aduser -Identity $user.split("@")[0] | Select-Object name
    $sccmdevicelists += $sccmdevicelist

} 
$date = get-date -Format "_MMddyy_HHmm"
$sccmdevicelists | export-csv -NoTypeInformation "c:\temp\$Vulnerability_Name$date.csv"



#remove above bracket if going to email
    if ($fullname -ne $null){
$body = "Hi $fullname, 

This is a notification that we have identified a security vulnerability with ($pluginname) that is installed on your device, $hostname.  We will attempt to remediate this vulnerability with the solution listed below.
    
If you have any issues with your application(s) or device after this update please contact Client Support at x26662 or feel free to reach out to me directly.

If you no longer need this application please let me know and we will remove it from your system.  

====================================================================================================================
Solution:

$solution



    
Thank you

Greg Westergren
Systems Engineer
An Employee of ettain group
Working at L.L.Bean, Inc.
gwestergre@llbean.com

    "
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject "Vulnerability $pluginid" -Body $body -Priority High -SmtpServer 'llb-ex01'
}
    Else {
    $body = "$hostname does not have a user associated with it"
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject "Vulnerability $pluginid has no user listed" -Body $body -Priority High -SmtpServer 'llb-ex01'
    }


