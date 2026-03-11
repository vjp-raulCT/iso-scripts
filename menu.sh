#!/bin/bash

# 1. Muestra la interfaz gráfica por terminal
show_menu() {
    clear
    echo "Menú"
    echo "------------------------------------------------------"
    echo "1. Fichero passwd ordenado por /home/* en columnas"
    echo "2. Listado de ficheros vacíos en el árbol de directorios"
    echo "3. Generar 200 números aleatorios y contar repeticiones"
    echo "4. Mostrar información del sistema utilizando neofetch y lolcat"
    echo "5. Listado coloreado con lolcat del directorio actual"
    echo "6. Salir"
    echo ""
    echo -n "Seleccione una opción: "
}

# 2. Lógica de ejecución basada en el argumento posicional ($1)
execute_command() {
    case $1 in
        1)
            # - grep: Filtra solo las líneas que contienen "/home"
            # - sort -t: -k6: Ordena usando ":" como separador por la 6ª columna
            # - nl -w1 -s:: Añade número de línea al principio, ajusta el ancho a 1 y usa ":" como separador
            # - column -t -s:: Tabula todo dinámicamente usando ":" como delimitador
	    grep "/home" /etc/passwd | sort -t ':' -k 6 | cat -n | tr ':' ' ' | column -t
            ;;
        2)
            # Busca recursivamente (.) ficheros (-type f) que no tengan contenido (-empty)
            find / -type f -empty 2>/dev/null | less
            ;;
        3)
            # Se limita el aleatorio a 100 (% 100) para forzar colisiones y que existan repeticiones evidentes.
            # uniq -c requiere que los datos estén previamente ordenados para poder contarlos.
            for i in {1..200}; do echo $((RANDOM % 100)); done | sort | uniq -c | sort -nr
            ;;
        4)
            # Nota: Si optaste por la solución moderna en Debian Trixie, cambia 'neofetch' por 'fastfetch' aquí.
            fastfetch | lolcat
            ;;
        5)
            # Formato largo (ocultos incluidos) pasado por el filtro de color
            ls -la | lolcat
            ;;
        6)
            echo "Saliendo del script..."
            exit 0
            ;;
        *)
            # Control de errores: Atrapa entradas vacías, letras o números fuera de rango.
            echo "Error: Opción inválida."
            ;;
    esac
}

# 3. Bucle infinito de control
while true; do
    show_menu
    read opcion
    echo "" # Salto de línea estético antes de mostrar el resultado
    
    execute_command "$opcion"
    
    echo ""
    echo -n "Presione Enter para continuar..."
    read # Congela la ejecución hasta que el usuario pulse Enter, permitiendo leer la salida
done
