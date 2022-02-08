$details = import-csv C:\temp\Detail_List.csv
$details."netbios name"

foreach ($item in $details){
    if ($item."netbios name" -ne $null) {$parts = $item."netbios name".Split('\')
        
    }
    # modify the header2 column in our csv input
    $parts[1]
#    $newDate = $parts[1] + " " + $parts[2] + " " + $parts[5]
#    $item.header2 = [DateTime]::Parse($newDate) | Get-Date -Format d
}


$detailgroups = $details | Group-Object -property plugin | Where-Object {$_.count -eq 1}  | Select-Object group 
$vulnerabilities = $detailgroups.group | Select-Object * 

$vulnerabilities | Where-Object {$_.hostname -eq $pcname} | Select-Object HostName, "DNS Name", Plugin, "Plugin Name", "Severity", "Plugin Output", Synopsis, Description, Solution


($detailgroups).count

[11]
#$pcname= Read-Host -Prompt "Enter system name"
#$vulnerabilities."plugin name"
#$detailgroups = $details | group -property hostname | where {$_.count -eq 1}  | select group 
#$singlehosts = $details.hostname | group | where {$_.count -eq 1}