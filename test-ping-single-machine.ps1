cls
#reads hostname from user input
$computer = Read-Host "Enter a hostname"

Write-Host "Testing $computer..."
        
#Tests name resolution for machine
$DNS_resolution = Resolve-DnsName -Name $computer -ErrorAction SilentlyContinue
if ($DNS_resolution -eq $null)
    {
        #message if DNS resolution fails
        Write-Host "DNS resolution for $computer failed, not attempting ping"
    }
else
    {
        #Tries to ping ip if name resolution succeeds
        $DNS_ping = Test-NetConnection -ComputerName $computer -ErrorAction SilentlyContinue
        
        if (($DNS_ping.PingSucceeded.ToString()) -eq "True")
            {
                #message if ping succeeds
                $DNS_ip = $DNS_ping.RemoteAddress.ToString()
                Write-Host "Pinging DNS ip of $computer succeeded: $DNS_ip"
            }
        else
            {
                #message if ping fails
                Write-Host "Ping of DNS ip of $computer failed"
            }
    }
           
#Queries the WSUS database on llb-sccm12pri01 for the machine hostname
$wsus_computer = Get-WsusServer -Name llb-sccm12pri01 -PortNumber 8530 | Get-WsusComputer -NameIncludes $computer -ErrorAction SilentlyContinue

#converts ip address of machine to string--needed otherwise write-host below returns the data type, not the actual ip value
$wsus_computer_ip = $wsus_computer.IPAddress.IPAddressToString 

#if ip address value is not null, attempt to ping it
if (($wsus_computer_ip) -ne $null)
    {
        $wsus_ping = Test-NetConnection $wsus_computer_ip 
        if (($wsus_ping.PingSucceeded.toString()) -eq "True")
            {
                Write-Host "Pinging WSUS ip for $computer succeeded: $wsus_computer_ip"
            }
        else
            {
                write-host "Pinging WSUS ip for $computer failed"
            }
    }
else
    {
        Write-Host "No ip address found in WSUS for $computer"
    }