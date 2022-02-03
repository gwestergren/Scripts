
$user = "gwestergre" + "@llbean.com"
$ADUser = Get-aduser -Identity $user.split("@")[0] | Select-Object name
$body = "Hi $ADUser, 

I'm with the Desktop Services team working for Carolyn Davis on our Vulnerability items and your pc, L3XM6K13-LP, showed up on our list as having Oracle Java vulnerabilities.

Options to resolve this vulnerability:
1. Upgrade/Update to the latest version
2. Remove the software if no longer needed
3. If unable to complete above options, allow me to log into your system to resolve the vulnerability

Please let me know if you have any questions and please notify me if/when this has been completed so that I can clear it from our list.

Thank you
"

Send-MailMessage -From 'Greg Westergren <gwestergre@llbean.com>' -To $user -Subject 'Vulnerability' -Body $body -Priority High -SmtpServer 'llb-ex01'



