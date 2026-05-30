@echo off
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [!] Administrator permission required. Please approve...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Cosmic Fix Tool
color 0A

set "cosmicPath=C:\Cosmic"
set "CURRENT_VER=1.0.3"
set "SELF=%~f0"
set "RAW_VER=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/FixCosmic.bat"

goto menu

:check_update
echo [*] Checking for updates...

powershell -NoProfile -NonInteractive -Command ^
  "$ErrorActionPreference='SilentlyContinue';" ^
  "$v=(Invoke-WebRequest '%RAW_VER%' -UseBasicParsing -TimeoutSec 5).Content.Trim();" ^
  "if($v -and $v -ne '%CURRENT_VER%'){" ^
  "  Invoke-WebRequest '%RAW_BAT%' -OutFile '%SELF%.new' -UseBasicParsing -TimeoutSec 15;" ^
  "  Write-Host $v" ^
  "} else { Write-Host $v }" ^
  > "%temp%\cosmic_ver.txt" 2>nul

set "LATEST_VER="
set /p LATEST_VER=<"%temp%\cosmic_ver.txt"
del "%temp%\cosmic_ver.txt" >nul 2>&1

if "%LATEST_VER%"=="" (
    echo [!] Could not check for updates. Continuing...
    goto menu
)

if "%CURRENT_VER%"=="%LATEST_VER%" (
    echo [+] Already up to date ^(v%CURRENT_VER%^).
    goto menu
)

if not exist "%SELF%.new" (
    echo [!] Update download failed. Continuing...
    goto menu
)

for %%F in ("%SELF%.new") do if %%~zF==0 (
    del "%SELF%.new" >nul 2>&1
    echo [!] Downloaded file is empty. Continuing...
    goto menu
)

echo [+] Updated to v%LATEST_VER%! Restarting...
echo move /y "%SELF%.new" "%SELF%" > "%temp%\cosmic_update.bat"
echo start "" "%SELF%" /updated >> "%temp%\cosmic_update.bat"
echo del "%temp%\cosmic_update.bat" >> "%temp%\cosmic_update.bat"
start "" cmd /c "timeout /t 2 >nul & "%temp%\cosmic_update.bat""
exit

:menu
cls
