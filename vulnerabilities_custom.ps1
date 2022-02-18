﻿#globals
$global:payloadcoll       = @()

$details = import-csv C:\temp\Detail_List.csv

#$detailgroups = $details | Group-Object -property plugin | Where-Object {$_.count -le 9}  | Select-Object group 
$detailgroups = $details | Where-Object {$_."plugin name" -like "*visual studio*"} | Select-Object *
$vulnerabilities = $detailgroups  
#$vulnerabilities = $detailgroups.group | Select-Object * 
$vulnerability = @()
$c1 = 0
#$hostname = @()
foreach ($item in $vulnerabilities){
    $c1++
    Write-Progress -Activity 'Checking servers with less then 9 vulnerabilities' -Status "Processing $($c1) of $($vulnerabilities.count)" -CurrentOperation $item."NetBIOS Name" -PercentComplete (($c1/$vulnerabilities.Count) * 100)

    if (($item."netbios name").Length -gt 1) {$parts = $item | Select-Object *, @{Name = 'Hostname'; Expression = {$_."netbios name".Split('\')[1]}}

    $vulnerability += $parts  
    }
    elseif (($item."dns name").Length -gt 1) {$parts = $item | Select-Object *, @{Name = 'Hostname'; Expression = {$_."dns name".Split('.')[0]}}

    $vulnerability += $parts 
    }
}
$vulnerability | export-csv -NoTypeInformation c:\temp\vul.csv
$c1 = 0
foreach ($item in $vulnerability){
    $c1++
    Write-Progress -Activity 'Sending emails' -Status "Processing $($c1) of $($vulnerability.count)" -CurrentOperation $item."NetBIOS Name" -PercentComplete (($c1/$vulnerability.Count) * 100)

    $sccmdevicelist = get-cmdevice -name $item.hostname | Select-Object *, @{Name = 'User'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}}

    $emailuser = $sccmdevicelist.LastLogonUser + "@llbean.com"
    $fullname = $sccmdevicelist.user
    $pluginname = $item."plugin name"
    $hostname = $item.hostname
#    $output = $item."plugin output"
#    $description = $item.description
    $solution = $item.Solution
    $pluginid = $item.Plugin
    #$ADUser = Get-aduser -Identity $user.split("@")[0] | Select-Object name

    if ($fullname -ne $null){
    $body = "Hi $fullname, 

    This is a notification that we have identified a security vulnerability with ($pluginname) that is installed on your device, $hostname.  We will attempt to remediate this vulnerability with the solution listed below.
    
    If you have any issues with your application(s) or device after this update please contact Client Support at x26662 or feel free to reach out to me directly.

    ====================================================================================================================
    Solution:

    Uninstall Visual Studio



    
    Thank you

    Greg Westergren
    Systems Engineer
    An Employee of ettain group
    Working at L.L.Bean, Inc.
    gwestergre@llbean.com

    "
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To $emailuser -Subject "Vulnerability $pluginid" -Body $body -Priority High -SmtpServer 'llb-ex01'
}
    Else {
    $body = "$hostname does not have a user associated with it"
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject "Vulnerability $pluginid has no user listed" -Body $body -Priority High -SmtpServer 'llb-ex01'
    }
}
