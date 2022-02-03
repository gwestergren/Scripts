get-content "C:\temp\Systems.txt" | foreach { Add-CMDeviceCollectionDirectMembershipRule -CollectionName "Remediation Item 78675 Winzip" -ResourceID (Get-CMDevice -Name $_).ResourceID }

ping -t DRW1GC008


ping 192.168.126.132


nslookup 192.168.132.75

Get-ADComputer -filter * -Properties name, CN, CanonicalName, dnshostname, Enabled, LastLogonDate, PasswordLastSet, PasswordExpired, whenChanged, whenCreated, OperatingSystem, OperatingSystemVersion | export-csv -NoTypeInformation c:\temp\computerlist.csv

$computers = Get-ADComputer -filter * -properties CanonicalName, LastLogonDate, PasswordLastSet, PasswordExpired, whenChanged, whenCreated, OperatingSystem, OperatingSystemVersion | select name, CanonicalName, dnshostname, Enabled, LastLogonDate, PasswordLastSet, PasswordExpired, whenChanged, whenCreated, OperatingSystem, OperatingSystemVersion 
foreach($computer in $computers){
    $pingtest = Test-Connection -ComputerName $computer.name -Quiet -Count 1 -ErrorAction SilentlyContinue
    if($pingtest){
         Write-Host -ForegroundColor Green ($computer.name + " is online")
     }
     else{
        Write-Host -ForegroundColor Red ($computer.name + " is not reachable")
     }
}


$offline = get-content C:\temp\Offline.txt
$results = foreach ($off in $offline){
Get-ADComputer -Filter 'Name -eq $off' -Properties name, CN, CanonicalName, dnshostname, Enabled, LastLogonDate, PasswordLastSet, PasswordExpired, whenChanged, whenCreated, OperatingSystem, OperatingSystemVersion
} 
$results | export-csv -NoTypeInformation c:\temp\offlinecomputerlist.csv
