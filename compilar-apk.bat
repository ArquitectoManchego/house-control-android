@echo off
title Compilar House Control APK
echo ========================================================
echo   Compilando House Control Android APK
echo ========================================================
cd /d "%~dp0"
set JAVA_HOME=C:\Users\Alex\AppData\Local\Programs\Eclipse Adoptium\jdk-21.0.8.9-hotspot\
set PATH=%JAVA_HOME%bin;%PATH%
call gradlew.bat assembleDebug
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo Compilacion exitosa!
    echo Tu APK se encuentra en:
    echo %~dp0app\build\outputs\apk\debug\app-debug.apk
    echo ========================================================
) else (
    echo.
    echo Ocurrio un error durante la compilacion.
)
pause
