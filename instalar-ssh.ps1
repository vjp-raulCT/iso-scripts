<#
.SYNOPSIS
    Instala, configura y habilita el servicio servidor SSH en Windows o Linux.

.DESCRIPTION
    Este script instala OpenSSH Server en sistemas Windows (usando características
    opcionales de Windows) o en sistemas Linux basados en apt.
    Configura el servicio para que se inicie automáticamente y lo habilita de inmediato.
    Requiere privilegios de administrador para ejecutarse.

.EXAMPLE
    .\instalar-ssh-server.ps1

    Instala y configura el servidor SSH en el sistema actual.

.NOTES
    Author:  ISO - Implantación de Sistemas Operativos
    License: GNU
    Fecha:   2026-03-18

.LINK
    https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
#>

#Requires -RunAsAdministrator

# ─────────────────────────────────────────────
# INSTALACIÓN EN LINUX (apt)
# ─────────────────────────────────────────────
if ($IsLinux) {
    Write-Host "Sistema Linux detectado. Instalando openssh-server con apt..." -ForegroundColor Cyan

    # Comprobación previa: ¿ya está instalado y en ejecución?
    $sshStatus = systemctl is-active ssh 2>$null
    if ($sshStatus -eq "active") {
        Write-Host "El servidor SSH ya está instalado y en ejecución. No es necesaria la instalación." -ForegroundColor Green
        exit 0
    }

    apt update
    apt install -y openssh-server
    systemctl enable ssh
    systemctl start ssh

    $sshStatus = systemctl is-active ssh 2>$null
    if ($sshStatus -eq "active") {
        Write-Host "Servidor SSH instalado y en ejecución correctamente." -ForegroundColor Green
    } else {
        Write-Host "ERROR: El servidor SSH no se ha podido iniciar." -ForegroundColor Red
    }
    exit 0
}

# ─────────────────────────────────────────────
# INSTALACIÓN EN WINDOWS
# ─────────────────────────────────────────────

Write-Host "Sistema Windows detectado." -ForegroundColor Cyan

# Comprobación previa: ¿ya está instalado y en ejecución?
$sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
$sshCapability = Get-WindowsCapability -Online -Name OpenSSH.Server* -ErrorAction SilentlyContinue

if ($sshService -and $sshService.Status -eq 'Running') {
    Write-Host "El servidor SSH ya está instalado y en ejecución. No es necesaria la instalación." -ForegroundColor Green
    exit 0
}

# Instalar OpenSSH Server si no está instalado
if ($null -eq $sshCapability -or $sshCapability.State -ne 'Installed') {
    Write-Host "Instalando OpenSSH Server..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    if ($?) {
        Write-Host "OpenSSH Server instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "ERROR: No se pudo instalar OpenSSH Server." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "OpenSSH Server ya estaba instalado como característica de Windows." -ForegroundColor Green
}

# Configurar el servicio sshd para inicio automático
Write-Host "Configurando el servicio sshd para inicio automático..." -ForegroundColor Yellow
Set-Service -Name sshd -StartupType Automatic

# Iniciar el servicio sshd
Write-Host "Iniciando el servicio sshd..." -ForegroundColor Yellow
Start-Service sshd

# Verificar estado final
$sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshService -and $sshService.Status -eq 'Running') {
    Write-Host "Servidor SSH instalado, configurado y en ejecución correctamente." -ForegroundColor Green
    Write-Host "Tipo de inicio: $($sshService.StartType)" -ForegroundColor Green
} else {
    Write-Host "ERROR: El servicio sshd no está en ejecución tras la instalación." -ForegroundColor Red
    exit 1
}

# Verificar/crear regla de Firewall para SSH (puerto 22)
$fwRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
if ($null -eq $fwRule) {
    Write-Host "Creando regla de Firewall para el puerto 22 (SSH)..." -ForegroundColor Yellow
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" `
        -DisplayName "OpenSSH Server (sshd)" `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22
    Write-Host "Regla de Firewall creada." -ForegroundColor Green
} else {
    Write-Host "La regla de Firewall para SSH ya existe." -ForegroundColor Green
}

Write-Host "`nInstalación completada. Puedes conectarte con: ssh usuario@$(hostname)" -ForegroundColor Cyan
