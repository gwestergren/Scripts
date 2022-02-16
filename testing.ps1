


$vulnerability | export-csv -NoTypeInformation c:\temp\vuls.csv

$temporary = $vulnerabilities.where{$_.'DNS Name' -ne ""} | Select-Object *, @{Name = 'Hostname'; Expression = {$_."dns name".Split('.')[0]}}
$temporary1 = $vulnerabilities.where{$_.'netbios name' -ne ""} | Select-Object *, @{Name = 'Hostname'; Expression = {$_."netbios name".Split('\')[1]}}

$vulnerabilities.where{$_.'netbios Name' -ne ""}
$vulnerabilities.foreach("DNS Name")

$vulnerabilities | Where-Object {$_.hostname -eq $pcname} | Select-Object HostName, "DNS Name", Plugin, "Plugin Name", "Severity", "Plugin Output", Synopsis, Description, Solution

($detailgroups).count

$pcname= Read-Host -Prompt "Enter system name"
$vulnerabilities."plugin name"
$detailgroups = $details | group -property hostname | where {$_.count -eq 1}  | select group 
$singlehosts = $details.hostname | group | where {$_.count -eq 1}

    if (($item."netbios name").Length -gt 1) {$parts = $item."netbios name".Split('\')[1]
    write-host -ForegroundColor Blue $parts
    $myObject = [PSCustomObject]@{
        HostName = $parts
        NetName = $item."netbios name"
        }