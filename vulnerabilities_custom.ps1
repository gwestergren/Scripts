#globals
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

Reboot of your system on 2/23/22 at 5pm EST.


    

    
Thank you

Greg Westergren
Systems Engineer
An Employee of ettain group
Working at L.L.Bean, Inc.
gwestergre@llbean.com

    "
#    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject "Vulnerability $pluginid" -Body $body -Priority High -SmtpServer 'llb-ex01'
}
    Else {
    $body = "$hostname does not have a user associated with it"
    Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To gwestergre@llbean.com -Subject "Vulnerability $pluginid has no user listed" -Body $body -Priority High -SmtpServer 'llb-ex01'
    }
}

#NOTE:  If you have the Adobe Creative Cloud icon on your desktop please update any and all adobe software there.  If you do not have an account or need permission, you can request it through ServiceNow in the Service Catalog.  
#    PC Software & Application Access ---> Adobe Identity Management service.