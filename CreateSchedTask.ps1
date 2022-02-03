schtasks /create /tn SCCMList1 /tr "c:\Scripts\sccm.ps1" /sc daily /st 06:30
schtasks /create /tn SCCMList2 /tr "c:\Scripts\sccm.ps1" /sc daily /st 12:30
