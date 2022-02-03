$file1 = Import-Csv -Path filesystem::"\\llb-pkg01\source\Remediation source\Reports\sccmdevicelist_012822_1231.csv"
$file2 = Import-Csv -Path filesystem::"\\llb-pkg01\source\Remediation source\Reports\sccmdevicelist_012822_0754.csv"

#Clear-Host
$array = Compare-Object -Property name, pingstatus $file1 $file2

$array