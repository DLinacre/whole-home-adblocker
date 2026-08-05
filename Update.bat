@echo off
title Whole-Home Ad Blocker - Update
color 0B
echo  Updating to the latest version (your settings and stats are kept)...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0wizard.ps1" -Update
pause
