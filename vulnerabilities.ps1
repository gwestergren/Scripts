#globals
$global:payloadcoll       = @()

$details = import-csv C:\temp\Detail_List.csv

$detailgroups = $details | Group-Object -property plugin | Where-Object {$_.count -le 3}  | Select-Object group 
$vulnerabilities = $detailgroups.group | Select-Object * 
$vulnerability = @()
$c1 = 0
#$hostname = @()
foreach ($item in $vulnerabilities){
    $c1++
    Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($vulnerabilities.count)" -CurrentOperation $item."NetBIOS Name" -PercentComplete (($c1/$vulnerabilities.Count) * 100)

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
    Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($vulnerability.count)" -CurrentOperation $item."NetBIOS Name" -PercentComplete (($c1/$vulnerability.Count) * 100)

    $sccmdevicelist = get-cmdevice -name $item.hostname | Select-Object *, @{Name = 'User'; Expression = {(Get-aduser -Identity $_.lastlogonuser).name}}

    $emailuser = $sccmdevicelist.LastLogonUser + "@llbean.com"
    $fullname = $sccmdevicelist.user
    $pluginname = $item."plugin name"
    $hostname = $item.hostname
    $output = $item."plugin output"
    $description = $item.description
    $solution = $item.Solution
    #$ADUser = Get-aduser -Identity $user.split("@")[0] | Select-Object name

    if ($fullname -ne $null){
    $body = "Hi $fullname, 

    I'm with the Desktop Services team working for Carolyn Davis on our Vulnerability items and your pc, $hostname, showed up on our list as having vulnerabilities with $pluginname.

    Description:

    $description
    ====================================================================================================================
    Vulnerability Output:
    
    $output
    ====================================================================================================================
    Solution:

    $solution
    
    ====================================================================================================================
    Options to resolve this vulnerability:
    1. Complete the solution listed above
    2. Remove the software if no longer needed
    3. If unable to complete above options, allow me to try to connect to your device and resolve
    4. If i'm unable to connect then please contact the help desk to help resolve vulnerability
    
    Please let me know if you have any questions and please notify me if/when this has been completed so that I can clear it from our list.
    
    Thank you
    "
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject 'Vulnerability' -Body $body -Priority High -SmtpServer 'llb-ex01'
}
    Else {
    $body = "$hostname does not have a user associated with it"
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject 'Vulnerability with no user' -Body $body -Priority High -SmtpServer 'llb-ex01'
    }
}

