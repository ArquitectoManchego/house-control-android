@echo off
title Desbloquear Sincronizacion Wi-Fi SketchUp
echo ==========================================================
echo   Habilitando conexion local Wi-Fi para House Control
echo ==========================================================
echo.
echo 1. Desactivando bloqueo de conexiones ENTRANTES locales hacia SketchUp...
echo    (La proteccion de salida hacia internet permanece intacta)
netsh advfirewall firewall set rule name="Block Sketchup" dir=in new enable=no
netsh advfirewall firewall set rule name="Block sketchup" dir=in new enable=no
echo.
echo 2. Habilitando puerto 8765 para la sincronizacion...
netsh advfirewall firewall add rule name="SketchUp House Control Sync 8765" dir=in action=allow protocol=TCP localport=8765 profile=any
echo.
echo ==========================================================
echo  Listo! El puerto 8765 ha sido habilitado con exito.
echo  Ahora puedes presionar "Probar" en tu celular.
echo ==========================================================
pause
