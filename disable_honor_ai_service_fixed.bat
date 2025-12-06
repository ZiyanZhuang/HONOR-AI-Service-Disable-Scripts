@echo off
echo ====================================
echo    HONOR AI Service Disable Script
echo ====================================
echo.

:: Check administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Administrator privileges detected
) else (
    echo [ERROR] Administrator privileges required
    echo Please right-click script and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Disabling HONOR AI Service...
echo.

:: 1. Kill related processes
echo [1/5] Terminating processes...
taskkill /f /im "HnPCAIService.exe" >nul 2>&1
taskkill /f /im "HNPCAIService.exe" >nul 2>&1
echo [OK] Processes terminated

:: 2. Stop Windows services
echo [2/5] Stopping services...
sc stop "HNPCAIService" >nul 2>&1
sc config "HNPCAIService" start= disabled >nul 2>&1
echo [OK] Services stopped

:: 3. Disable scheduled tasks
echo [3/5] Disabling scheduled tasks...
schtasks /change /tn "HONOR\AI*" /disable >nul 2>&1
schtasks /delete /tn "HONOR\AI*" /f >nul 2>&1
echo [OK] Scheduled tasks processed

:: 4. Clean registry startup entries
echo [4/5] Cleaning registry...
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "HNPCAIService" /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "HNPCAIService" /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "HnPCAIService" /f >nul 2>&1
echo [OK] Registry cleaned

:: 5. Verify disable status
echo [5/5] Verifying status...
timeout /t 2 >nul
tasklist | findstr /i "HnPCAIService.exe" >nul
if %errorLevel% == 0 (
    echo [WARNING] Service still running detected
) else (
    echo [SUCCESS] Service successfully disabled
)

echo.
echo ====================================
echo        Disable Complete!
echo ====================================
echo.
echo If service restarts, you may need to:
echo 1. Run this script again
echo 2. Check for other related processes
echo 3. Consider uninstalling HONOR software
echo.
pause