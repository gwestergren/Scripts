get-content "C:\temp\Systems.txt" | ForEach-Object { Add-CMDeviceCollectionDirectMembershipRule -CollectionName "Remediation Item Reboot Machines" -ResourceID (Get-CMDevice -Name $_).ResourceID }
