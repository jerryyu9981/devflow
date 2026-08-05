@echo off
chcp 65001 >nul
echo ========================================
echo   DevFlow Plugin Installer
echo ========================================
echo.
echo Starting installation wizard...
echo.

:: Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell is not available on this system.
    echo Please install PowerShell or run install.ps1 manually.
    pause
    exit /b 1
)

:: Run the PowerShell installer with bypass execution policy
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Installation failed. See error messages above.
    pause
    exit /b 1
)

exit /b 0
