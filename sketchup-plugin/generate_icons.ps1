Add-Type -AssemblyName System.Drawing

function Create-CatalogIcon([int]$size, [string]$path) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Fondo oscuro redondeado
    $dim = [int]($size - 2)
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(21, 26, 36))
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 229, 255), [float][Math]::Max(1.0, $size / 16.0))
    $g.FillEllipse($bgBrush, 1, 1, $dim, $dim)
    $g.DrawEllipse($borderPen, 1, 1, $dim, $dim)

    # Cubo isométrico 3D estilo Lumion
    $cx = [float]($size / 2.0)
    $cy = [float]($size / 2.0)
    $r = [float]($size * 0.32)

    $pTop = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new($cx, $cy - $r),
        [System.Drawing.PointF]::new([float]($cx + $r * 0.86), [float]($cy - $r * 0.5)),
        [System.Drawing.PointF]::new($cx, $cy),
        [System.Drawing.PointF]::new([float]($cx - $r * 0.86), [float]($cy - $r * 0.5))
    )
    $pLeft = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new([float]($cx - $r * 0.86), [float]($cy - $r * 0.5)),
        [System.Drawing.PointF]::new($cx, $cy),
        [System.Drawing.PointF]::new($cx, $cy + $r),
        [System.Drawing.PointF]::new([float]($cx - $r * 0.86), [float]($cy + $r * 0.5))
    )
    $pRight = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new([float]($cx + $r * 0.86), [float]($cy - $r * 0.5)),
        [System.Drawing.PointF]::new($cx, $cy),
        [System.Drawing.PointF]::new($cx, $cy + $r),
        [System.Drawing.PointF]::new([float]($cx + $r * 0.86), [float]($cy + $r * 0.5))
    )

    $topBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 229, 255))
    $leftBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 112, 243))
    $rightBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 198, 255))

    $g.FillPolygon($topBrush, $pTop)
    $g.FillPolygon($leftBrush, $pLeft)
    $g.FillPolygon($rightBrush, $pRight)

    $cubePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255), [float]1.0)
    $g.DrawPolygon($cubePen, $pTop)
    $g.DrawPolygon($cubePen, $pLeft)
    $g.DrawPolygon($cubePen, $pRight)

    $g.Dispose()
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created successfully: $path"
}

$iconDir = 'C:\PROYECTOS ANTIGRAVITY\house-control-sketchup-sync\house_control_sync\icons'
if (-not (Test-Path $iconDir)) { New-Item -ItemType Directory -Path $iconDir -Force | Out-Null }
Create-CatalogIcon 16 (Join-Path $iconDir 'catalog_16.png')
Create-CatalogIcon 24 (Join-Path $iconDir 'catalog_24.png')
Create-CatalogIcon 32 (Join-Path $iconDir 'catalog_32.png')
