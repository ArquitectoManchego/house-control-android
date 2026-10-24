@echo off
title House Control - Modo Web 3D
echo ========================================================
echo   Iniciando House Control (Modelo 3D y Panel Interactivo)
echo ========================================================
cd /d "%~dp0web"
echo Abriendo en el navegador en http://localhost:5199/?platform=android ...
start http://localhost:5199/?platform=android
call npx vite --port 5199
pause
