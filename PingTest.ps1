
#$computers = Get-ADComputer -filter * -properties CanonicalName, LastLogonDate, PasswordLastSet, PasswordExpired, whenChanged, whenCreated, OperatingSystem, OperatingSystemVersion | select name, CanonicalName, dnshostname, Enabled, LastLogonDate, PasswordLastSet, PasswordExpired, whenChanged, whenCreated, OperatingSystem, OperatingSystemVersion 


foreach($computer in $computers){
    $pingtest = Test-Connection -ComputerName $computer.name -Quiet -Count 1 -ErrorAction SilentlyContinue
    if($pingtest){
         Write-Host -ForegroundColor Green ($computer.name + " is online")
     }
     else{
        Write-Host -ForegroundColor Red ($computer.name + " is not reachable")
     }
}




