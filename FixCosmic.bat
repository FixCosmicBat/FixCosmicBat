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
set "CURRENT_VER=1.0.1"
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
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [1]  Fix Roblox Crash on Inject (CFG + DirectX + Fishstrap)
echo [2]  Fix Injector / Module Error
echo [3]  Fix Login Error
echo [4]  Fix Antivirus Exclusion (C:\Cosmic)
echo [5]  Fix Error 0x1  - Anti-Tamper Failed
echo [6]  Fix Error 0x2  - Hardware ID Failed
echo [7]  Fix Error 0x3  - Empty Server Response
echo [8]  Fix Error 0x5  - Malformed Server Response
echo [9]  Fix Error 0x6  - Server Rejected Login
echo [10] Fix Error 0x7  - No Session Token
echo [11] Fix Error 0x8  - Hardware ID Failed (SecureAuth)
echo [12] Fix Error 0x9  - Empty Server Response (SecureAuth)
echo [13] Fix Error 0x10 - Server Rejected SecureAuth
echo [14] Fix Error 0x11 - Malformed Server Response (SecureAuth)
echo [15] Fix Error 0x12 - Anti-Tamper Failed (Authenticate)
echo [16] Fix Error 0x13 - Missing Credentials
echo [17] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1"  goto fix_roblox_crash
if "%choice%"=="2"  goto fix_injector
if "%choice%"=="3"  goto fix_login
if "%choice%"=="4"  goto fix_exclusion
if "%choice%"=="5"  goto err_0x1
if "%choice%"=="6"  goto err_0x2
if "%choice%"=="7"  goto err_0x3
if "%choice%"=="8"  goto err_0x5
if "%choice%"=="9"  goto err_0x6
if "%choice%"=="10" goto err_0x7
if "%choice%"=="11" goto err_0x8
if "%choice%"=="12" goto err_0x9
if "%choice%"=="13" goto err_0x10
if "%choice%"=="14" goto err_0x11
if "%choice%"=="15" goto err_0x12
if "%choice%"=="16" goto err_0x13
if "%choice%"=="17" exit

goto menu

:kill_synapse
tasklist /FI "IMAGENAME eq Synapse Launcher.exe" | find /I "Synapse Launcher.exe" >nul
if errorlevel 1 (
    echo [*] Synapse is not running.
) else (
    echo [*] Killing Synapse...
    taskkill /f /im "Synapse Launcher.exe" /t >nul 2>&1
    taskkill /f /im Synapse.exe /t >nul 2>&1
    taskkill /f /im SynapseInjector.exe /t >nul 2>&1
    powershell -NoProfile -Command "Get-Process -Name *Synapse* -ErrorAction SilentlyContinue | Stop-Process -Force"
    timeout /t 2 >nul
)
goto :eof

:clean_network
echo [*] Cleaning network settings...
echo # Copyright (c) 1993-2009 Microsoft Corp. > "%SystemRoot%\System32\drivers\etc\hosts"
echo 127.0.0.1       localhost >> "%SystemRoot%\System32\drivers\etc\hosts"
echo ::1             localhost >> "%SystemRoot%\System32\drivers\etc\hosts"
ipconfig /flushdns >nul
taskkill /f /im "Fiddler.exe" /t >nul 2>&1
taskkill /f /im "Fiddler4.exe" /t >nul 2>&1
taskkill /f /im "FiddlerAnywhere.exe" /t >nul 2>&1
taskkill /f /im "Wireshark.exe" /t >nul 2>&1
taskkill /f /im "Charles.exe" /t >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
goto :eof

:restart_wmi
echo [*] Restarting WMI service...
net stop winmgmt /y >nul 2>&1
net start winmgmt >nul 2>&1
net stop "WMI Performance Adapter" /y >nul 2>&1
net start "WMI Performance Adapter" >nul 2>&1
goto :eof

:reset_network_stack
echo [*] Resetting network stack...
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
goto :eof

:fix_roblox_crash
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [Fix] Roblox crashes when injecting
echo.
echo [*] Disabling Control Flow Guard (CFG) for Roblox...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v DisableDynamicCodeWin32k /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RobloxPlayerBeta.exe" /v MitigationOptions /t REG_BINARY /d 01000000000000000000000000000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RobloxStudioBeta.exe" /v MitigationOptions /t REG_BINARY /d 01000000000000000000000000000000 /f >nul 2>&1
echo [+] CFG disabled.

echo [*] Downloading DirectX Web Installer to Desktop...
powershell -NoProfile -Command "Invoke-WebRequest 'https://download.microsoft.com/download/1/7/1/1718ccc4-6315-4d8e-9543-8e28a4e18c4c/dxwebsetup.exe' -OutFile '%USERPROFILE%\Desktop\dxwebsetup.exe'"
if exist "%USERPROFILE%\Desktop\dxwebsetup.exe" (
    echo [*] Installing DirectX silently...
    start /wait "" "%USERPROFILE%\Desktop\dxwebsetup.exe" /Q
    echo [+] DirectX installation completed.
) else (
    echo [!] DirectX download failed. Please install manually from https://www.microsoft.com/en-us/download/details.aspx?id=35
)

echo [*] Downloading Fishstrap to Desktop...
powershell -NoProfile -Command "Invoke-WebRequest 'https://github.com/fishstrap/fishstrap/releases/latest/download/Fishstrap.exe' -OutFile '%USERPROFILE%\Desktop\Fishstrap.exe'"

if exist "%USERPROFILE%\Desktop\Fishstrap.exe" (
    echo [+] Fishstrap downloaded to Desktop.
    echo [*] Launching Fishstrap installer...
    start "" "%USERPROFILE%\Desktop\Fishstrap.exe"
) else (
    echo [!] Fishstrap download failed. Please download manually from https://fishstrap.app
)

echo.
echo [!] Please complete the Fishstrap installation (choose installation folder etc.).
echo [!] After installation is finished, close Fishstrap if it opens.
echo.
pause
echo [*] Searching for Fishstrap FastFlags.json...

set "fishstrapPath="
if exist "%LOCALAPPDATA%\Fishstrap\FastFlags.json" set "fishstrapPath=%LOCALAPPDATA%\Fishstrap\FastFlags.json"
if not defined fishstrapPath if exist "%APPDATA%\Fishstrap\FastFlags.json" set "fishstrapPath=%APPDATA%\Fishstrap\FastFlags.json"
if not defined fishstrapPath if exist "%USERPROFILE%\Documents\Fishstrap\FastFlags.json" set "fishstrapPath=%USERPROFILE%\Documents\Fishstrap\FastFlags.json"
if not defined fishstrapPath if exist "%ProgramFiles%\Fishstrap\FastFlags.json" set "fishstrapPath=%ProgramFiles%\Fishstrap\FastFlags.json"
if not defined fishstrapPath if exist "%ProgramFiles(x86)%\Fishstrap\FastFlags.json" set "fishstrapPath=%ProgramFiles(x86)%\Fishstrap\FastFlags.json"

if defined fishstrapPath (
    echo [*] Found Fishstrap config: %fishstrapPath%
    echo [*] Setting Rendering Mode to Direct3D11...
    powershell -NoProfile -Command "$json = Get-Content '%fishstrapPath%' -Raw | ConvertFrom-Json; $json.RenderingMode = 'Direct3D11'; $json | ConvertTo-Json | Set-Content '%fishstrapPath%'"
    echo [+] Rendering mode updated.
) else (
    echo [*] Could not find FastFlags.json; creating it...
    set "fishstrapFolder=%LOCALAPPDATA%\Fishstrap"
    if not exist "%fishstrapFolder%" mkdir "%fishstrapFolder%"
    echo { "RenderingMode": "Direct3D11" } > "%fishstrapFolder%\FastFlags.json"
    echo [+] FastFlags.json created with RenderingMode set to Direct3D11.
)

echo.
echo [+] All fixes applied! Restart Roblox and try injecting again.
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:fix_injector
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
call :kill_synapse

echo [*] Cleaning old files...
attrib -r -s -h "%cosmicPath%\Cosmic-Injector.exe" 2>nul
attrib -r -s -h "%cosmicPath%\Cosmic-Module.dll" 2>nul
del /f /q "%cosmicPath%\Cosmic-Injector.exe" >nul 2>&1
del /f /q "%cosmicPath%\Cosmic-Module.dll" >nul 2>&1

echo [*] Downloading fix files...
powershell -NoProfile -Command "Invoke-WebRequest 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/injector_fix.zip/injector_fix.zip' -OutFile '%temp%\injector_fix.zip'"

echo [*] Extracting...
powershell -NoProfile -Command "Expand-Archive -Path '%temp%\injector_fix.zip' -DestinationPath '%temp%\cosmic_fix' -Force"

echo [*] Replacing files...
copy /y "%temp%\cosmic_fix\Cosmic-Injector.exe" "%cosmicPath%\" >nul
copy /y "%temp%\cosmic_fix\Cosmic-Module.dll" "%cosmicPath%\" >nul

echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:fix_login
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
call :kill_synapse

echo [*] Removing credentials...
attrib -r -s -h "%cosmicPath%\Credentials.dat" 2>nul
del /f /q "%cosmicPath%\Credentials.dat" >nul 2>&1

echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:fix_exclusion
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [*] Adding C:\Cosmic to Windows Defender exclusions...
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%cosmicPath%' -ErrorAction SilentlyContinue"
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x1
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x1] Anti-Tamper Failed
echo Cause: Modified hosts file, DNS hijacking or proxy software.
echo.
call :clean_network
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x2
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x2] Hardware ID Failed
echo Cause: WMI service issues or restricted system permissions.
echo.
call :restart_wmi
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x3
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x3] Empty Server Response
echo Cause: Network or connectivity issue.
echo.
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
call :reset_network_stack
echo [*] Killing proxy tools...
taskkill /f /im "Fiddler.exe" /t >nul 2>&1
taskkill /f /im "Fiddler4.exe" /t >nul 2>&1
taskkill /f /im "Wireshark.exe" /t >nul 2>&1
taskkill /f /im "Charles.exe" /t >nul 2>&1
echo.
echo [!] A system restart may be required.
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x5
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x5] Malformed Server Response
echo Cause: A network proxy or firewall is injecting content.
echo.
call :clean_network
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x6
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x6] Server Rejected Login
echo Cause: Invalid credentials or account issue.
echo.
echo [*] Removing saved credentials...
attrib -r -s -h "%cosmicPath%\Credentials.dat" 2>nul
del /f /q "%cosmicPath%\Credentials.dat" >nul 2>&1
echo.
echo [!] Use your Cosmic USERNAME, not your email.
echo [!] If issue persists, check your account at cosmic.best
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x7
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x7] No Session Token
echo Cause: Initial login did not complete successfully.
echo.
echo [*] Removing saved credentials...
attrib -r -s -h "%cosmicPath%\Credentials.dat" 2>nul
del /f /q "%cosmicPath%\Credentials.dat" >nul 2>&1
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
echo.
echo [!] Please re-login when Synapse launches.
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x8
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x8] Hardware ID Failed (SecureAuth)
echo Cause: Hardware fingerprint failed during secure authentication.
echo.
call :restart_wmi
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x9
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x9] Empty Server Response (SecureAuth)
echo Cause: Secure authentication server returned an empty response.
echo.
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
call :reset_network_stack
echo.
echo [!] A system restart may be required.
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x10
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x10] Server Rejected SecureAuth
echo Cause: License invalid, expired, or HWID has changed.
echo.
echo [*] Removing saved credentials...
attrib -r -s -h "%cosmicPath%\Credentials.dat" 2>nul
del /f /q "%cosmicPath%\Credentials.dat" >nul 2>&1
echo.
echo [!] If license expired, renew at cosmic.best
echo [!] If HWID changed, contact support: discord.gg/getcosmic
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x11
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x11] Malformed Server Response (SecureAuth)
echo Cause: Secure authentication response could not be parsed.
echo.
call :clean_network
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x12
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x12] Anti-Tamper Failed (Authenticate)
echo Cause: Same as 0x1 but during automatic authentication flow.
echo.
call :clean_network
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menu

:err_0x13
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo   Made by Syno317 / BlackStageX
echo ==============================
echo.
echo [0x13] Missing Credentials
echo Cause: No saved credentials found or credentials file is corrupted.
echo.
echo [*] Removing corrupted credentials file...
attrib -r -s -h "%cosmicPath%\Credentials.dat" 2>nul
del /f /q "%cosmicPath%\Credentials.dat" >nul 2>&1
echo.
echo [!] Please re-login when Synapse launches.
echo.
echo [+] The issue is fixed, enjoy!
echo.
echo   Made by Syno317 / BlackStageX
echo.
pause
goto menuv
