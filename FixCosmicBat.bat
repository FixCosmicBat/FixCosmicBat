@echo off
title Cosmic Fix Tool
color 0B

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

:kill_synapse
echo [*] Killing Synapse...

taskkill /f /im "Synapse Launcher.exe" /t >nul 2>&1
taskkill /f /im Synapse.exe /t >nul 2>&1
taskkill /f /im SynapseInjector.exe /t >nul 2>&1

wmic process where "name like '%%Synapse%%'" delete >nul 2>&1

timeout /t 2 >nul
goto :eof

:fix_injector
cls
call :kill_synapse

echo [*] Cleaning old files...
del /f /q C:\Cosmic\Cosmic-Injector >nul 2>&1
del /f /q C:\Cosmic\Cosmic-Module.dll >nul 2>&1

echo [*] Downloading fix files...
powershell -Command "Invoke-WebRequest 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/injector_fix.zip/injector_fix.zip' -OutFile '%temp%\injector_fix.zip'"

echo [*] Extracting...
powershell -Command "Expand-Archive -Path '%temp%\injector_fix.zip' -DestinationPath '%temp%\cosmic_fix' -Force"

echo [*] Replacing files...
copy /y "%temp%\cosmic_fix\Cosmic-Injector" C:\Cosmic\ >nul
copy /y "%temp%\cosmic_fix\Cosmic-Module.dll" C:\Cosmic\ >nul

echo.
echo [+] Injector / Module Fix Completed!
pause
goto menu

:fix_login
cls
call :kill_synapse

echo [*] Removing Credentials...
del /f /q C:\Cosmic\Credentials.dat >nul 2>&1

echo.
echo [+] Login Fix Completed!
pause
goto menu
