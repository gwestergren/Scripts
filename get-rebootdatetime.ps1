$TenHosts = import-csv -Path C:\temp\detail_list.csv

$group = $TenHosts |Group-Object name| Select-Object * 

$sccmdevicelists = @()
$c1 = 0
Foreach ($tenhost in $group){
$c1++
Write-Progress -Activity 'Checking servers' -Status "Processing $($c1) of $($group.count)" -CurrentOperation $tenhost.name -PercentComplete (($c1/$group.Count) * 100)

if (((Test-Connection -ComputerName $tenhost.name -Quiet -Count 1 -ErrorAction SilentlyContinue) -eq $true) -and ($tenhost.name -notlike "vdics*")){
$sccmdevicelist = Get-WmiObject win32_operatingsystem -computername $tenhost.name | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
$sccmdevicelists += $sccmdevicelist
Write-host -ForegroundColor blue $TenHost.name online
}
else {
$sccmdevicelist = [PSCustomObject]@{
        csname = $tenhost.name
        LastBootUpTime = "Not accessible"}

$sccmdevicelists += $sccmdevicelist
Write-host -ForegroundColor red $TenHost.name offline
}
}
$date = get-date -Format "_MMddyy_HHmm"pi
$sccmdevicelists | export-csv -NoTypeInformation "c:\temp\detail_list_reboot$date.csv"


#Get-CimInstance -ClassName win32_operatingsystem -computername $tenhost.name | select csname, lastbootuptime
#Get-WmiObject win32_operatingsystem -computername 192.168.126.182 | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
#Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}pin


#query user /server:192.168.126.182
