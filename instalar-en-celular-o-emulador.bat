@echo off
title Instalar House Control APK
echo ========================================================
echo   Instalando House Control APK en dispositivo Android
echo ========================================================
set ADB="C:\Users\Alex\AppData\Local\Android\Sdk\platform-tools\adb.exe"
echo Dispositivos detectados:
%ADB% devices
echo.
echo Instalando APK debug...
%ADB% install -r "%~dp0app\build\outputs\apk\debug\app-debug.apk"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo APK instalado correctamente.
    echo Abriendo House Control en tu dispositivo...
    %ADB% shell am start -n dev.housecontrol.android.debug/dev.housecontrol.android.MainActivity
    echo ========================================================
) else (
    echo.
    echo No se pudo instalar el APK directamente.
    echo Asegurate de:
    echo 1. Tener tu dispositivo conectado por cable USB con 'Depuracion USB' habilitada.
    echo 2. O tener el emulador Android encendido.
    echo.
    echo Tambien puedes copiar manualmente el archivo APK a tu telefono:
    echo %~dp0app\build\outputs\apk\debug\app-debug.apk
)
pause
