<#
.SYNOPSIS
    Muestra información de espacio en GB de una unidad de disco.

.DESCRIPTION
    El script comprobar-espacio-unidad.ps1 obtiene y muestra el espacio total,
    libre y ocupado (en GB, redondeados a 2 decimales) de la unidad especificada,
    usando el cmdlet Get-PSDrive.

    Si el espacio ocupado supera el 90% del total, o el espacio libre es inferior
    a 2 GB, se mostrará una advertencia con fondo rojo.

.PARAMETER Unidad
    Letra de la unidad de disco a comprobar (sin los dos puntos).
    Por defecto se comprueba la unidad C.

.EXAMPLE
    .\comprobar-espacio-unidad.ps1
    Comprueba el espacio de la unidad C (valor por defecto).

.EXAMPLE
    .\comprobar-espacio-unidad.ps1 -Unidad D
    Comprueba el espacio de la unidad D.

.INPUTS
    Ninguno. No acepta entrada por la tubería (pipeline).

.OUTPUTS
    System.String. Muestra la información de espacio en consola.

.NOTES
    Nombre      : comprobar-espacio-unidad.ps1
    Autor       : Administrador de sistemas
    Fecha       : 2026-03-17
    Versión     : 1.0
    Requisitos  : PowerShell 5.1 o superior

.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-psdrive

.LINK
    https://learn.microsoft.com/en-us/powershell/scripting/developer/help/examples-of-comment-based-help
#>

param (
    # Letra de la unidad a comprobar (sin los dos puntos). Por defecto: C
    [string]$Unidad = "C"
)

# ── Obtener datos de la unidad ─────────────────────────────────────────────────
$drive = Get-PSDrive -Name $Unidad

# Bytes libres y usados que expone Get-PSDrive
$FreeSpaceBytes = $drive.Free
$UsedSpaceBytes = $drive.Used
$TotalSpaceBytes = $FreeSpaceBytes + $UsedSpaceBytes

# ── Convertir a GB y redondear a 2 decimales ───────────────────────────────────
$TotalGB = [Math]::Round($TotalSpaceBytes / 1GB, 2)
$FreeGB  = [Math]::Round($FreeSpaceBytes  / 1GB, 2)
$UsedGB  = [Math]::Round($UsedSpaceBytes  / 1GB, 2)

# ── Calcular porcentaje ocupado ────────────────────────────────────────────────
$UsedPercent = [Math]::Round(($UsedSpaceBytes / $TotalSpaceBytes) * 100, 2)

# ── Mostrar resultados ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Información de espacio - Unidad ${Unidad}:" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Espacio total  : $TotalGB GB"
Write-Host "  Espacio libre  : $FreeGB GB"
Write-Host "  Espacio ocupado: $UsedGB GB ($UsedPercent %)"
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ── Advertencia si espacio ocupado > 90% o libre < 2 GB ───────────────────────
if ($UsedPercent -gt 90 -or $FreeGB -lt 2) {
    Write-Host " ¡ADVERTENCIA! " -ForegroundColor White -BackgroundColor Red -NoNewline
    Write-Host ""
    if ($UsedPercent -gt 90) {
        Write-Host " El espacio ocupado ($UsedPercent %) supera el 90% del total. " `
            -ForegroundColor White -BackgroundColor Red
    }
    if ($FreeGB -lt 2) {
        Write-Host " El espacio libre ($FreeGB GB) es inferior a 2 GB. " `
            -ForegroundColor White -BackgroundColor Red
    }
    Write-Host " Considere liberar espacio en la unidad ${Unidad}: lo antes posible. " `
        -ForegroundColor White -BackgroundColor Red
    Write-Host ""
}