.SYNOPSIS
    Muestra espacio libre y utilizado de todos los sitemas de ficheros.

.DESCRIPTION
    Muestra todas las unidades/drives indicando el espacio libre y utilizado en GB.
    Utiliza Get-PSDrive para obtener las unidades de tipo FileSystem activas
    en la sesión actual y las presenta en formato tabla con Format-Table.

.EXAMPLE
    PS> .\resumen-discos.ps1

    Name Root  Utilizado(GB) Libre(GB)
    ---- ----  ------------- ---------
    C    C:\         110,00       8,60
    D    D:\         903,60      27,90

.NOTES
    Author:  ISO - Implantación de Sistemas Operativos
    License: GNU
    Fecha:   2026-03-18

.LINK
    https://github.com/ISO-VJP/iso-scripts-vjp-idGitHub
#>

# Obtener todas las unidades FileSystem con espacio conocido (Used/Free no nulos)
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object {
    $_.Used -ne $null -and $_.Free -ne $null
}

# Construir tabla con los datos en GB redondeados a 2 decimales
$tabla = $drives | Select-Object `
    @{ Name = 'Name';           Expression = { $_.Name } },
    @{ Name = 'Root';           Expression = { $_.Root } },
    @{ Name = 'Utilizado(GB)';  Expression = { [Math]::Round($_.Used  / 1GB, 2) } },
    @{ Name = 'Libre(GB)';      Expression = { [Math]::Round($_.Free  / 1GB, 2) } }

# Mostrar en formato tabla
$tabla | Format-Table -AutoSize