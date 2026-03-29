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

:menu
cls
echo ==============================
echo      COSMIC FIX TOOL
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
:: Synapse Launch (Desktop\06w99o\publish)
:: -------------------------------
:launch_synapse
echo [*] Searching for 06w99o folder on Desktop...

set "found="
for /d %%D in ("%USERPROFILE%\Desktop\06w99o") do (
    if exist "%%D\publish\Synapse Launcher.exe" (
        set "found=%%D\publish\Synapse Launcher.exe"
        goto :found_synapse
    )
)

echo [!] 06w99o folder or Synapse Launcher not found on Desktop!
goto :eof

:found_synapse
echo [+] Found Synapse at: %found%

tasklist /FI "IMAGENAME eq Synapse Launcher.exe" | find /I "Synapse Launcher.exe" >nul
if errorlevel 1 (
    echo [*] Launching Synapse...
    start "" "%found%"
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
:: Kullanımda olabilir, önce Synapse veya modülleri kill et
tasklist /FI "IMAGENAME eq Synapse.exe" | find /I "Synapse.exe" >nul
if %errorlevel%==0 (
    echo [*] Synapse process running, killing...
    taskkill /f /im "Synapse.exe" /t >nul 2>&1
)

:: Dosyaları force sil ve read-only / hidden / system flag temizle
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
call :launch_synapse
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
call :launch_synapse
pause
goto menu
