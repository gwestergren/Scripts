
$details = import-csv C:\temp\Detail_List.csv
#$singlehosts = $details.hostname | group | where {$_.count -eq 1}

#$detailgroups = $details | group -property hostname | where {$_.count -eq 1}  | select group 
$detailgroups = $details | Group-Object -property plugin | Where-Object {$_.count -eq 1}  | Select-Object group 
$vulnerabilities = $detailgroups.group | Select-Object * 


$vulnerabilities | Where-Object {$_.hostname -eq $pcname} | Select-Object HostName, "DNS Name", Plugin, "Plugin Name", "Severity", "Plugin Output", Synopsis, Description, Solution


($detailgroups).count





#$pcname= Read-Host -Prompt "Enter system name"


#$vulnerabilities."plugin name"





