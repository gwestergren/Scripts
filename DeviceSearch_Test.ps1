
$files = Get-ChildItem -path filesystem::'\\llb-pkg01\source\Remediation source\Reports\sccmdevicelist*.csv' | Select-Object -ExpandProperty FullName
$count = $files.count

if ($count -le 7){
$userlist = foreach ($file in $files){
$filename = ($file.Split("\")[-1]).split(".")[0]
$filedate = (($filename.Split("\")[-1]).split("_"))[1] 
$filetime = (($filename.Split("\")[-1]).split("_"))[2]

Import-CSV -Path filesystem::$file | Select-Object *,@{Name='filedate';Expression={$filedate}},@{Name='filetime';Expression={$filetime}}
                                    }
                     }

$pcname= Read-Host -Prompt "Enter system name"
$userlist | Where-Object {$_.name -eq $pcname} | Format-Table name, LastActiveTime, IsActive, UserName, User, PingStatus, FileDate, FileTime


#@{n=”Date”;e={$getdate}}
#$userlist | Add-Member -MemberType NoteProperty -Name 'FileDate' -Value $filedate
#$userlist | Add-Member -MemberType NoteProperty -Name 'FileTime' -Value $filetime

#| Select-Object *,@{Name='site';Expression={'0'}},@{Name='trace';Expression={$files[$i].FullName}}