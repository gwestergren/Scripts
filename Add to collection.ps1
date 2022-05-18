get-content "C:\temp\Systems.txt" | ForEach-Object { Add-CMDeviceCollectionDirectMembershipRule -CollectionName "Remediation Item 158168 Zoom Client < 5.8.4" -ResourceID (Get-CMDevice -Name $_).ResourceID }

get-content "C:\temp\Systems.txt" | ForEach-Object { Add-CMDeviceCollectionDirectMembershipRule -CollectionName "Remediation Item 58134 Microsoft Silverlight Unsupported Version" -ResourceID (Get-CMDevice -Name $_).ResourceID }
