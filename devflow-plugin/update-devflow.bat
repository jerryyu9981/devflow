@echo off
title DevFlow Updater

echo ========================================
echo   DevFlow One-Click Update
echo ========================================
echo.

cd /d "%~dp0"

echo [1/2] Syncing skills to TRAE...
powershell -ExecutionPolicy Bypass -File "%~dp0sync-skills.ps1" -Action Sync -Target All

echo.
echo ========================================
echo   [DONE] Update complete!
echo.
echo   Next step: Restart TRAE IDE to load new skills
echo ========================================
echo.
pause
