$paths=@(
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
)
foreach($path in $paths){
  Get-ChildItem -Path $path | 
    Get-ItemProperty | 
      Select DisplayName, Publisher, InstallDate, DisplayVersion
}