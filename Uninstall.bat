@echo off
title Whole-Home Ad Blocker - Uninstall
color 0C
echo ============================================================
echo    Removing the ad blocker
echo ============================================================
echo.
docker rm -f adguardhome >nul 2>&1
echo Container removed.
echo.
set /p DEL="Also delete your settings, stats and saved password? (y/N): "
if /i "%DEL%"=="y" (
    rmdir /s /q "%~dp0adguard" >nul 2>&1
    del "%~dp0dashboard-password.txt" >nul 2>&1
    echo All settings deleted.
) else (
    echo Settings kept - reinstall with Install.bat anytime.
)
echo.
echo Done. Docker Desktop can be removed from Windows Settings - Apps
echo if you no longer need it.
echo.
pause
