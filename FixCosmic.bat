@echo off
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [!] Administrator permission required. Please approve...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Cosmic Fix Tool
color 0B

set "cosmicPath=C:\Cosmic"
set "CURRENT_VER=1.0.0"
set "SELF=%~f0"
set "RAW_VER=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/FixCosmic.bat"

if "%1"=="/updated" goto menu

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
echo [1]  Fix Injector / Module Error
echo [2]  Fix Login Error
echo [3]  Fix Antivirus Exclusion
echo [4]  Fix Error 0x1  - Anti-Tamper Failed
echo [5]  Fix Error 0x2  - Hardware ID Failed
echo [6]  Fix Error 0x3  - Empty Server Response
echo [7]  Fix Error 0x5  - Malformed Server Response
echo [8]  Fix Error 0x6  - Server Rejected Login
echo [9]  Fix Error 0x7  - No Session Token
echo [10] Fix Error 0x8  - Hardware ID Failed (SecureAuth)
echo [11] Fix Error 0x9  - Empty Server Response (SecureAuth)
echo [12] Fix Error 0x10 - Server Rejected SecureAuth
echo [13] Fix Error 0x11 - Malformed Server Response (SecureAuth)
echo [14] Fix Error 0x12 - Anti-Tamper Failed (Authenticate)
echo [15] Fix Error 0x13 - Missing Credentials
echo [16] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1"  goto fix_injector
if "%choice%"=="2"  goto fix_login
if "%choice%"=="3"  goto fix_exclusion
if "%choice%"=="4"  goto err_0x1
if "%choice%"=="5"  goto err_0x2
if "%choice%"=="6"  goto err_0x3
if "%choice%"=="7"  goto err_0x5
if "%choice%"=="8"  goto err_0x6
if "%choice%"=="9"  goto err_0x7
if "%choice%"=="10" goto err_0x8
if "%choice%"=="11" goto err_0x9
if "%choice%"=="12" goto err_0x10
if "%choice%"=="13" goto err_0x11
if "%choice%"=="14" goto err_0x12
if "%choice%"=="15" goto err_0x13
if "%choice%"=="16" exit

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
    wmic process where "name like '%%Synapse%%'" delete >nul 2>&1
    timeout /t 2 >nul
)
goto :eof

:launch_synapse
echo [*] Searching for Synapse Launcher.exe on all drives...
set "found="

for %%X in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%X:\" (
        for /r "%%X:\" %%F in ("Synapse Launcher.exe") do (
            if not defined found (
                set "found=%%~fF"
            )
        )
    )
)

if not defined found (
    echo [!] Synapse Launcher.exe not found on any drive!
    goto :eof
)

goto :found_synapse

:found_synapse
echo [+] Found: %found%
tasklist /FI "IMAGENAME eq Synapse Launcher.exe" | find /I "Synapse Launcher.exe" >nul
if errorlevel 1 (
    echo [*] Launching Synapse...
    start "" "%found%"
    timeout /t 3 >nul
) else (
    echo [*] Synapse is already running.
)
goto :eof

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
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%cosmicPath%'"

echo [*] Searching for Synapse Launcher.exe on all drives...
set "synapsefolder="

for %%X in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%X:\" (
        for /r "%%X:\" %%F in ("Synapse Launcher.exe") do (
            if not defined synapsefolder (
                set "synapsefolder=%%~dpF"
            )
        )
    )
)

if not defined synapsefolder (
    echo [!] Synapse Launcher.exe not found, skipping...
    goto :exclusion_done
)

echo [*] Found Synapse at: %synapsefolder%
echo [*] Adding Synapse folder to Windows Defender exclusions...
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%synapsefolder%'"

:exclusion_done
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
echo [*] Resetting hosts file...
echo # Copyright (c) 1993-2009 Microsoft Corp. > "%SystemRoot%\System32\drivers\etc\hosts"
echo 127.0.0.1       localhost >> "%SystemRoot%\System32\drivers\etc\hosts"
echo ::1             localhost >> "%SystemRoot%\System32\drivers\etc\hosts"
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
echo [*] Killing proxy tools...
taskkill /f /im "Fiddler.exe" /t >nul 2>&1
taskkill /f /im "Fiddler4.exe" /t >nul 2>&1
taskkill /f /im "FiddlerAnywhere.exe" /t >nul 2>&1
taskkill /f /im "Wireshark.exe" /t >nul 2>&1
taskkill /f /im "Charles.exe" /t >nul 2>&1
echo [*] Disabling proxy settings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
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
echo [*] Restarting WMI service...
net stop winmgmt /y >nul 2>&1
net start winmgmt >nul 2>&1
net stop "WMI Performance Adapter" /y >nul 2>&1
net start "WMI Performance Adapter" >nul 2>&1
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
echo [*] Resetting network stack...
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
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
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
echo [*] Killing proxy tools...
taskkill /f /im "Fiddler.exe" /t >nul 2>&1
taskkill /f /im "Fiddler4.exe" /t >nul 2>&1
taskkill /f /im "FiddlerAnywhere.exe" /t >nul 2>&1
taskkill /f /im "Wireshark.exe" /t >nul 2>&1
taskkill /f /im "Charles.exe" /t >nul 2>&1
echo [*] Disabling proxy settings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
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
echo [*] Restarting WMI service...
net stop winmgmt /y >nul 2>&1
net start winmgmt >nul 2>&1
net stop "WMI Performance Adapter" /y >nul 2>&1
net start "WMI Performance Adapter" >nul 2>&1
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
echo [*] Resetting network stack...
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
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
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
echo [*] Killing proxy tools...
taskkill /f /im "Fiddler.exe" /t >nul 2>&1
taskkill /f /im "Fiddler4.exe" /t >nul 2>&1
taskkill /f /im "Wireshark.exe" /t >nul 2>&1
taskkill /f /im "Charles.exe" /t >nul 2>&1
echo [*] Disabling proxy settings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
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
echo [*] Resetting hosts file...
echo # Copyright (c) 1993-2009 Microsoft Corp. > "%SystemRoot%\System32\drivers\etc\hosts"
echo 127.0.0.1       localhost >> "%SystemRoot%\System32\drivers\etc\hosts"
echo ::1             localhost >> "%SystemRoot%\System32\drivers\etc\hosts"
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul
echo [*] Killing proxy tools...
taskkill /f /im "Fiddler.exe" /t >nul 2>&1
taskkill /f /im "Fiddler4.exe" /t >nul 2>&1
taskkill /f /im "Wireshark.exe" /t >nul 2>&1
taskkill /f /im "Charles.exe" /t >nul 2>&1
echo [*] Disabling proxy settings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
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
goto menu
