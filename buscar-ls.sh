#!/bin/bash

# Función de ayuda
function ayuda() {
    echo "Uso: $0 <ruta> [opciones]"
    echo "Opciones:"
    echo "  -t (f|d)     Buscar archivos (f) o directorios (d)"
    echo "  -x          Limitar la búsqueda al sistema de archivos actual"
    echo "  -o <archivo> Guardar salida en un archivo"
    echo "  -r <regex>   Filtrar salida usando expresión regular"
    echo "  -d <n>       Buscar archivos modificados hace más de n días"
    echo "  -m <n>       Buscar archivos modificados hace más de n meses"
    echo "  -a <n>       Buscar archivos modificados hace más de n años"
    exit 1
}

# Función auxiliar para verificar argumentos requeridos
function cortarFaltaOpcion() {
    if [[ -z "$1" ]]; then
        echo "Falta el parámetro para $2"
        ayuda
    fi
}

# Variables de control
tiempo=0
usaTiempo=false
usaDev=false
usaType=false
usaRegex=false
usaSalida=false
usaNivel=false

# Validar mínimo 1 parámetro (ruta)
if [[ $# -lt 1 ]]; then
    ayuda
fi

ruta="$1"

if [[ ! -e "$ruta" ]]; then
    echo "Ruta no válida: $ruta"
    exit 1
fi

# Parseo de opciones
shift # quitar la ruta del primer argumento

for (( ; $# >= 2; )); do 
    case "$1" in
        -d)
            cortarFaltaOpcion "$2" "-d"
            usaTiempo=true
            tiempo=$((tiempo + $2))
            shift 2
            ;;
        -m)
            cortarFaltaOpcion "$2" "-m"
            usaTiempo=true
            tiempo=$((tiempo + 30 * $2))
            shift 2
            ;;
        -a)
            cortarFaltaOpcion "$2" "-a"
            usaTiempo=true
            tiempo=$((tiempo + 365 * $2))
            shift 2
            ;;
        -t)
            cortarFaltaOpcion "$2" "-t"
            if [[ "$2" == "f" || "$2" == "d" ]]; then
                usaType=true
                tipo="$2"
            else
                echo "Error: Tipo inválido. Usar 'f' para ficheros o 'd' para directorios."
                exit 1
            fi
            shift 2
            ;;
        -n)
            cortarFaltaOpcion "$2" "-n"
            usaNivel=true
            nivel=$2
            shift 2
        ;;
        -x)
            usaDev=true
            shift
            ;;
        -o)
            cortarFaltaOpcion "$2" "-o"
            usaSalida=true
            salida="$2"
            shift 2
            ;;
        -e)
            # re robe esta opcion julian perdon 
            cortarFaltaOpcion "$2" "-r"
            usaRegex=true
            regex="$2"
            shift 2
            ;;
        *)
            echo "Opción inválida: $1"
            ayuda
            ;;
    esac
done

# Armar partes del comando
comando="find \"$ruta\""

if $usaType; then
    comando+=" -type $tipo"
fi

if $usaNivel; then
    comando+=" -maxdepth $nivel"
fi

if $usaDev; then
    comando+=" -xdev"
fi

if $usaTiempo; then
    comando+=" -mtime $tiempo"
fi


comando+=" -exec ls -l {} \; "

# Ejecutar comando
if $usaRegex; then
    comando+=" | grep -E \"$regex\b\""
fi

if $usaSalida; then
    eval "$comando" > "$salida"
else
    eval "$comando"
fi
