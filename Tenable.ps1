$accesskey = 'accesskey'
$secretkey = 'secretkey'
$URL = 'https://sec-scan-sc01/rest/repository'
$headers = @{} 
$headers.Add("x-apikey", "accessKey=$accesskey;secretKey=$secretkey")
Invoke-RestMethod -Uri $URL -Method GET -Headers $headers | ConvertTo-Json >  output.txt











