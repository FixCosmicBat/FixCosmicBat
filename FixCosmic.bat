@echo off
:: -------------------------------
:: Yönetici kontrolü (UAC)
:: -------------------------------
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [!] Yönetici izni gerekiyor. Lütfen onay verin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Cosmic Fix Tool
color 0B

set "cosmicPath=C:\Cosmic"
set "CURRENT_VER=1.0.0"
set "RAW_VER=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/FixCosmic.bat"

:: -------------------------------
:: Güncelleme Kontrolü
:: -------------------------------
:check_update
echo [*] Checking for updates...
powershell -Command "(Invoke-WebRequest '%RAW_VER%' -UseBasicParsing).Content.Trim()" > "%temp%\cosmic_ver.txt" 2>nul
set /p LATEST_VER=<"%temp%\cosmic_ver.txt"
del "%temp%\cosmic_ver.txt" >nul 2>&1

if "%LATEST_VER%"=="" (
    echo [!] Could not check for updates. Continuing...
    goto menu
)

if "%CURRENT_VER%"=="%LATEST_VER%" (
    echo [+] Already up to date ^(v%CURRENT_VER%^).
    timeout /t 1 >nul
    goto menu
)

echo [!] New version found: v%LATEST_VER% ^(current: v%CURRENT_VER%^)
echo [*] Downloading update...
powershell -Command "Invoke-WebRequest '%RAW_BAT%' -OutFile '%~f0.new' -UseBasicParsing"

if not exist "%~f0.new" (
    echo [!] Update download failed. Continuing with current version...
    goto menu
)

echo [*] Applying update and restarting...
move /y "%~f0.new" "%~f0" >nul 2>&1
start "" "%~f0"
exit /b

:menu
cls
echo ==============================
echo      COSMIC FIX TOOL v%CURRENT_VER%
echo ==============================
echo.
echo [1] Fix Injector / Module Error
echo [2] Fix Login Error
echo [3] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" goto fix_injector
if "%choice%"=="2" goto fix_login
if "%choice%"=="3" exit

goto menu

:: -------------------------------
:: Synapse Kill (sadece açıksa)
:: -------------------------------
:kill_synapse
tasklist /FI "IMAGENAME eq Synapse Launcher.exe" | find /I "Synapse Launcher.exe" >nul
if errorlevel 1 (
    echo [*] Synapse not running.
) else (
    echo [*] Killing Synapse...
    taskkill /f /im "Synapse Launcher.exe" /t >nul 2>&1
    taskkill /f /im Synapse.exe /t >nul 2>&1
    taskkill /f /im SynapseInjector.exe /t >nul 2>&1
    wmic process where "name like '%%Synapse%%'" delete >nul 2>&1
    timeout /t 2 >nul
)
goto :eof

:: -------------------------------
:: Synapse Ara ve Başlat (Tüm sürücüler)
:: -------------------------------
:launch_synapse
echo [*] Searching for 06w99o folder on all drives...

set "found="

:: Tüm sürücüleri tara (A-Z)
for %%X in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%X:\06w99o\publish\Synapse Launcher.exe" (
        set "found=%%X:\06w99o\publish\Synapse Launcher.exe"
        goto :found_synapse
    )
)

echo [!] 06w99o folder or Synapse Launcher.exe not found on any drive!
goto :eof

:found_synapse
echo [+] Found Synapse at: %found%

tasklist /FI "IMAGENAME eq Synapse Launcher.exe" | find /I "Synapse Launcher.exe" >nul
if errorlevel 1 (
    echo [*] Launching Synapse...
    start "" "%found%"
    timeout /t 3 >nul
) else (
    echo [*] Synapse already running.
)
goto :eof

:: -------------------------------
:: FIX 1 - Injector / Module
:: -------------------------------
:fix_injector
cls
call :kill_synapse

echo [*] Cleaning old files...
tasklist /FI "IMAGENAME eq Synapse.exe" | find /I "Synapse.exe" >nul
if %errorlevel%==0 (
    echo [*] Synapse process running, killing...
    taskkill /f /im "Synapse.exe" /t >nul 2>&1
)

attrib -r -s -h "%cosmicPath%\Cosmic-Injector.exe" 2>nul
attrib -r -s -h "%cosmicPath%\Cosmic-Module.dll" 2>nul
del /f /q "%cosmicPath%\Cosmic-Injector.exe" >nul 2>&1
del /f /q "%cosmicPath%\Cosmic-Module.dll" >nul 2>&1

echo [*] Downloading fix files...
powershell -Command "Invoke-WebRequest 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/injector_fix.zip/injector_fix.zip' -OutFile '%temp%\injector_fix.zip'"

echo [*] Extracting...
powershell -Command "Expand-Archive -Path '%temp%\injector_fix.zip' -DestinationPath '%temp%\cosmic_fix' -Force"

echo [*] Replacing files...
copy /y "%temp%\cosmic_fix\Cosmic-Injector.exe" %cosmicPath%\ >nul
copy /y "%temp%\cosmic_fix\Cosmic-Module.dll" %cosmicPath%\ >nul

echo.
echo [+] Injector / Module Fix Completed!
echo.
pause
goto menu

:: -------------------------------
:: FIX 2 - Login
:: -------------------------------
:fix_login
cls
call :kill_synapse

echo [*] Removing Credentials...
attrib -r -s -h "%cosmicPath%\Credentials.dat" 2>nul
del /f /q "%cosmicPath%\Credentials.dat" >nul 2>&1

echo.
echo [+] Login Fix Completed!
echo.
pause
goto menu
