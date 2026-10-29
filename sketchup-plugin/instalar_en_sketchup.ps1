# Script para instalar House Control 3D Sync en todas las versiones instaladas de SketchUp
$ErrorActionPreference = "Stop"

$sourceFile = "$PSScriptRoot\house_control_sync.rb"
$sourceDir  = "$PSScriptRoot\house_control_sync"

$appData = [Environment]::GetFolderPath('ApplicationData')
$suRoot  = Join-Path $appData "SketchUp"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Instalando House Control 3D Sync en SketchUp" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Buscando instalaciones de SketchUp en: $suRoot" -ForegroundColor Yellow

$installedCount = 0

if (Test-Path $suRoot) {
    $suVersions = Get-ChildItem -Path $suRoot -Directory | Where-Object { $_.Name -like "SketchUp 20*" }
    
    foreach ($ver in $suVersions) {
        $pluginsPath = Join-Path $ver.FullName "SketchUp\Plugins"
        if (Test-Path $pluginsPath) {
            Write-Host "Instalando en $($ver.Name)..." -ForegroundColor Yellow
            
            # Copiar cargador principal .rb
            Copy-Item -Path $sourceFile -Destination (Join-Path $pluginsPath "house_control_sync.rb") -Force
            
            # Copiar directorio de la extensión
            $destDir = Join-Path $pluginsPath "house_control_sync"
            if (Test-Path $destDir) {
                Remove-Item -Path $destDir -Recurse -Force
            }
            Copy-Item -Path $sourceDir -Destination $destDir -Recurse -Force
            
            Write-Host " -> Instalado con exito en $($ver.Name)!" -ForegroundColor Green
            $installedCount++
        }
    }
}

if ($installedCount -gt 0) {
    Write-Host "`nExtension instalada con exito en $installedCount version(es) de SketchUp." -ForegroundColor Green
    Write-Host "Abre SketchUp y encontraras el menu 'House Control 3D' en Extensiones/Plugins y una nueva barra de herramientas." -ForegroundColor Cyan
} else {
    Write-Host "`nNo se encontraron carpetas de Plugins de SketchUp activas." -ForegroundColor Red
}

Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
