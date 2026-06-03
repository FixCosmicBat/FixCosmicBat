@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
title Cosmic Fix Tool v2.0.3
color 5
set "CURRENT_VERSION=2.0.3"
set "VERSION_URL=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/main/version.txt"
set "BAT_URL=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/main/FixCosmic.bat"
set "UPDATE_TEMP=%TEMP%\FixCosmic_new.bat"
set "UPDATER_TEMP=%TEMP%\CosmicUpdater.bat"
if "%1"=="--updated" goto :MAIN_MENU
echo =====================================
echo         Cosmic Fix Tool v%CURRENT_VERSION%
echo        Made by Syno317
echo =====================================
echo.
echo Checking for updates...
powershell -ExecutionPolicy Bypass -Command "try { $v = (Invoke-WebRequest -Uri '%VERSION_URL%' -TimeoutSec 5 -UseBasicParsing).Content.Trim(); Set-Content -Path '%TEMP%\cv.txt' -Value $v -NoNewline } catch { }" >nul 2>&1
if not exist "%TEMP%\cv.txt" (
    echo [Update] Could not reach update server. Continuing with current version.
    echo.
    goto :MAIN_MENU
)
set /p LATEST_VERSION=<"%TEMP%\cv.txt"
del "%TEMP%\cv.txt" >nul 2>&1
if "%LATEST_VERSION%"=="%CURRENT_VERSION%" (
    echo [Update] Already up to date ^(v%CURRENT_VERSION%^).
    echo.
    goto :MAIN_MENU
)
echo [Update] New version found: v%LATEST_VERSION% ^(current: v%CURRENT_VERSION%^)
echo Downloading update...
powershell -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%BAT_URL%' -OutFile '%UPDATE_TEMP%' -UseBasicParsing } catch { }" >nul 2>&1
if not exist "%UPDATE_TEMP%" (
    echo [Update] Download failed. Continuing with current version.
    echo.
    goto :MAIN_MENU
)
set "SELF=%~f0"
(
    echo @echo off
    echo ping -n 3 127.0.0.1 ^>nul
    echo copy /Y "%UPDATE_TEMP%" "%SELF%" ^>nul
    echo del /F /Q "%UPDATE_TEMP%"
    echo del /F /Q "%TEMP%\cv.txt" 2^>nul
    echo start "" "%SELF%" --updated
    echo del /F /Q "%UPDATER_TEMP%"
) > "%UPDATER_TEMP%"
echo [Update] Update downloaded. Restarting with new version...
start "" "%UPDATER_TEMP%"
exit /b
:MAIN_MENU
cls
echo =====================================
echo       Cosmic Fix Tool v%CURRENT_VERSION%
echo        Made by Syno317
echo =====================================
echo.
echo Select the fix you want to apply:
echo.
echo   1. Injection / Crash Fix
echo   2. Login Fix (Network Reset)
echo   3. Exit
echo.
set /p CHOICE=Enter your choice (1-3): 
if "%CHOICE%"=="1" goto :INJECTION_CRASH_FIX
if "%CHOICE%"=="2" goto :LOGIN_FIX
if "%CHOICE%"=="3" exit /b
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto :MAIN_MENU
:KILL_COSMIC
echo Closing any running Cosmic processes...
for %%P in (UI.exe Cosmic.exe cosmic.exe CosmicClient.exe Cosmic_Bootstrapper.exe) do (
    taskkill /F /IM "%%P" >nul 2>&1
)
timeout /t 2 /nobreak >nul
goto :EOF
:INJECTION_CRASH_FIX
cls
echo =====================================
echo     Injection / Crash Fix Selected
echo =====================================
echo.
echo IMPORTANT: Cosmic MUST be OPEN before running this fix.
echo.
set /p CONFIRM1=Is Cosmic currently open? (Y/N): 
if /I not "%CONFIRM1%"=="Y" (
    echo.
    echo Please open Cosmic and run the fix again.
    pause
    goto :MAIN_MENU
)
echo.
set /p CONFIRM2=Do you want to start the repair process? (Y/N): 
if /I not "%CONFIRM2%"=="Y" (
    echo.
    echo Operation cancelled.
    pause
    goto :MAIN_MENU
)
echo.
echo Detecting Cosmic installation...
echo.
for /f "delims=" %%i in ('powershell -Command "(Get-Process UI -ErrorAction SilentlyContinue).Path"') do set "COSMIC_EXE=%%i"
if not defined COSMIC_EXE (
    for /f "delims=" %%i in ('powershell -Command "(Get-Process Cosmic -ErrorAction SilentlyContinue).Path"') do set "COSMIC_EXE=%%i"
)
if not defined COSMIC_EXE (
    echo [ERROR] Could not detect Cosmic automatically.
    set /p COSMIC_EXE=Enter full path to Cosmic executable manually: 
    if not exist "%COSMIC_EXE%" (
        echo File not found. Aborting.
        pause
        goto :MAIN_MENU
    )
)
for %%F in ("%COSMIC_EXE%") do set "COSMIC_DIR=%%~dpF"
set "BIN_DIR=%COSMIC_DIR%bin"
set "COSMIC_DATA=%LOCALAPPDATA%\com.savage.cosmic"
set "EBZIP=%TEMP%\EBWebView.zip"
set "EBTEMP=%TEMP%\EBWebViewFix"
set "BINZIP=%TEMP%\bin.zip"
set "BINTEMP=%TEMP%\BinFix"
echo Cosmic Path:
echo %COSMIC_EXE%
echo.
call :KILL_COSMIC
echo.
echo [1/4] Removing old EBWebView...
if exist "%COSMIC_DATA%\EBWebView" (
    rmdir /s /q "%COSMIC_DATA%\EBWebView"
)
echo.
echo [2/4] Downloading latest EBWebView...
powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/Ebwiev/EBWebView.zip' -OutFile '%EBZIP%' -UseBasicParsing"
if not exist "%EBZIP%" (
    echo.
    echo [ERROR] Failed to download EBWebView.
    pause
    goto :MAIN_MENU
)
if exist "%EBTEMP%" rmdir /s /q "%EBTEMP%"
powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%EBZIP%' -DestinationPath '%EBTEMP%' -Force"
if exist "%EBTEMP%\EBWebView" (
    xcopy "%EBTEMP%\EBWebView" "%COSMIC_DATA%\EBWebView\" /E /H /C /I /Y >nul
) else (
    xcopy "%EBTEMP%" "%COSMIC_DATA%\EBWebView\" /E /H /C /I /Y >nul
)
del /F /Q "%EBZIP%" >nul 2>&1
rmdir /s /q "%EBTEMP%" >nul 2>&1
echo.
echo [3/4] Replacing bin folder...
if exist "%BIN_DIR%" (
    rmdir /s /q "%BIN_DIR%"
)
echo.
echo Downloading latest bin folder...
powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/Bin/bin.zip' -OutFile '%BINZIP%' -UseBasicParsing"
if not exist "%BINZIP%" (
    echo.
    echo [ERROR] Failed to download bin folder.
    pause
    goto :MAIN_MENU
)
if exist "%BINTEMP%" rmdir /s /q "%BINTEMP%"
powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%BINZIP%' -DestinationPath '%BINTEMP%' -Force"
if exist "%BINTEMP%\bin" (
    xcopy "%BINTEMP%\bin" "%BIN_DIR%\" /E /H /C /I /Y >nul
) else (
    xcopy "%BINTEMP%" "%BIN_DIR%\" /E /H /C /I /Y >nul
)
del /F /Q "%BINZIP%" >nul 2>&1
rmdir /s /q "%BINTEMP%" >nul 2>&1
echo.
echo [4/4] Adding Windows Defender exclusions...
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%LOCALAPPDATA%\com.savage.cosmic'" >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionProcess 'UI.exe'" >nul 2>&1
echo.
echo Restarting Cosmic...
if exist "%COSMIC_EXE%" (
    start "" "%COSMIC_EXE%"
)
echo.
echo =====================================
echo       INJECTION/CRASH FIX COMPLETED
echo        Made by Syno317
echo =====================================
echo.
echo Cosmic has been repaired and restarted.
echo.
pause
goto :MAIN_MENU
:LOGIN_FIX
cls
echo =====================================
echo        Login Fix (Network Reset)
echo =====================================
echo.
echo This will reset your network settings to resolve login issues.
echo Commands to be executed:
echo   - ipconfig /flushdns
echo   - ipconfig /release
echo   - ipconfig /renew
echo   - netsh winsock reset
echo   - netsh int ip reset
echo.
set /p CONFIRM=Do you want to continue? (Y/N): 
if /I not "%CONFIRM%"=="Y" (
    echo.
    echo Operation cancelled.
    pause
    goto :MAIN_MENU
)
echo.
echo Flushing DNS cache...
ipconfig /flushdns
echo.
echo Releasing current IP address...
ipconfig /release
echo.
echo Renewing IP address...
ipconfig /renew
echo.
echo Resetting Winsock catalog...
netsh winsock reset
echo.
echo Resetting TCP/IP stack...
netsh int ip reset
echo.
echo Network reset completed. It is recommended to restart your PC.
echo.
pause
goto :MAIN_MENU
