@echo off
title Habilitar Puerto 8765 para House Control Sync
echo ========================================================
echo   Configurando Firewall de Windows para SketchUp Sync
echo ========================================================
netsh advfirewall firewall add rule name="SketchUp House Control Sync 8765" dir=in action=allow protocol=TCP localport=8765 profile=any
echo.
echo Puerto 8765 habilitado con exito.
pause
