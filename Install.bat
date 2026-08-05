@echo off
title Whole-Home Ad Blocker - Setup Wizard
color 0B
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0wizard.ps1"
pause
