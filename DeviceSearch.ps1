$pcname= Read-Host -Prompt "Enter system name"
$files = Get-ChildItem -path filesystem::'\\llb-pkg01\source\Remediation source\Reports\sccmdevicelist*.csv' | Select-Object -ExpandProperty FullName -Last 20

$userlist = foreach ($file in $files){
$filename = ($file.Split("\")[-1]).split(".")[0]
$filedate = (($filename.Split("\")[-1]).split("_"))[1] 
$filetime = (($filename.Split("\")[-1]).split("_"))[2]

Import-CSV -Path filesystem::$file | Select-Object *,@{Name='filedate';Expression={$filedate}},@{Name='filetime';Expression={$filetime}}
                                    }

$userlist | Where-Object {$_.name -eq $pcname} | Format-Table -AutoSize name, LastActiveTime, IsActive, CNIsOnline, UserName, User, PingStatus, FileDate, FileTime
