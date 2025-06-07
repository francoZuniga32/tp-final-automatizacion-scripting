#!/bin/bash

# Función de ayuda
function ayuda() {
    echo "Uso: $0 <ruta> [opciones]"
    echo "Opciones:"
    echo "  -t (f|d)     Buscar archivos (f) o directorios (d)"
    echo "  -x          Limitar la búsqueda al sistema de archivos actual"
    echo "  -o <archivo> Guardar salida en un archivo"
    echo "  -d <n>       Buscar archivos modificados hace más de n días"
    echo "  -m <n>       Buscar archivos modificados hace más de n meses"
    echo "  -a <n>       Buscar archivos modificados hace más de n años"
    echo " -u <usuario>  Buscar archivos por usuario o ID de usuario"
    echo " -g <grupo>    Buscar archivos por grupo o ID de grupo"
    echo " -e <tipo de archivo>	Buscar archivos por extencion de archivo (por ejemplo .jpg)"
    exit 1
}

# Función auxiliar para verificar argumentos requeridos
function cortarFaltaOpcion() {
    if [[ -z "$1" ]]; then
        echo "Falta el parámetro para $2"
        ayuda
    fi
}

function extensionValida(){
    # Regex para extensiones comunes, como .txt, .jpg, .tar.gz, etc.
    if [[ ! $1 =~ \.([a-zA-Z0-9]{1,5})$ ]]; then
        echo "Extensión inválida"
        ayuda
    fi
}

function comprobarFecha(){
    fecha=$1
    if [[ "$fecha" =~ ^[0-9]{8}$ ]]; then
        if ! date -d "${fecha:0:4}-${fecha:4:2}-${fecha:6:2}" +"%Y%m%d" &>/dev/null; then
            echo "La fecha $fecha no es válida"
            ayuda
        fi
    else
        echo "Formato de facha incorrecto: $fecha"
        ayuda
    fi
}

function comprobarExclusionMutua(){
    if [[ "$1" == "true" || "$2" == "true" ]]; then
        echo "$3"
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
usaUsuario=false
usaGrupo=false
usaRegex=false
usaPermiso=false
usaFechaInicioModificacion=false
usaFechaFinalModificacion=false
usaFechaInicioAlta=false
usaFechaFinalAlta=false
usaEjecucion=false

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
for (( ; $# >= 1; )); do 
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
            usaEjecucion=true
            shift 1
        ;;
        -o)
            cortarFaltaOpcion "$2" "-o"
            usaSalida=true
            salida="$2"
            shift 2
            ;;
        -e)
            # re robe esta opcion julian perdon
            cortarFaltaOpcion "$2" "-e"
            extensionValida "$2" "-e"
            usaRegex=true
            regex="$2"
            shift 2
            ;;
        -u)
	    	cortarFaltaOpcion "$2" "-u"
	    	usaUsuario=true
		    usuario="$2"
            shift 2
	    	;;
	    -g)
		    cortarFaltaOpcion "$2" "-u"
		    usaGrupo=true
		    grupo="$2"
            shift 2
		    ;;
        -p)
            cortarFaltaOpcion "$2" "-p"
            usaPermiso=true
            permiso="$2"
            shift 2
        ;;
        -modificacionfechainicio)
            cortarFaltaOpcion "$2" "-fechainicio"
            comprobarFecha "$2"
            comprobarExclusionMutua "$usaFechaInicioAlta" "$usaFechaFinalAlta" "No se puede usar -altafechainicio o -altafechafinal junto con los opciones de -modificacionfechainicio -modificacionfechafinal"
            usaFechaInicioModificacion=true
            fechaInicioModificacion=$(bash diasEntre.sh $2)
            shift 2
        ;;
        -modificacionfechafinal)
            cortarFaltaOpcion "$2" "-fechafinal"
            comprobarFecha "$2"
            comprobarExclusionMutua "$usaFechaInicioAlta" "$usaFechaFinalAlta" "No se puede usar -altafechainicio o -altafechafinal junto con los opciones de -modificacionfechainicio -modificacionfechafinal"
            usaFechaFinalModificacion=true
            fechaFinalModificacion=$(bash diasEntre.sh $2)
            shift 2
        ;;
        -altafechainicio)
            cortarFaltaOpcion "$2" "-fechainicio"
            comprobarFecha "$2"
            comprobarExclusionMutua "$usaFechaInicioModificacion" "$usaFechaFinalModificacion" "No se puede usar -modificacionfechainicio o -modificacionfechafinal junto con los opciones de -altafechainicio , -altafechafinal"
            usaFechaInicioAlta=true
            fechaInicioAlta=$(bash diasEntre.sh $2)
            shift 2
        ;;
        -altafechafinal)
            cortarFaltaOpcion "$2" "-fechafinal"
            comprobarFecha "$2"
            comprobarExclusionMutua "$usaFechaInicioModificacion" "$usaFechaFinalModificacion" "No se puede usar -modificacionfechainicio o -modificacionfechafinal junto con los opciones de -altafechainicio , -altafechafinal"
            usaFechaFinalAlta=true
            fechaFinalAlta=$(bash diasEntre.sh $2)
            shift 2
        ;;
        -h)
            ayuda
        ;;
        *)
            echo "Opción inválida: $1"
            ayuda
        ;;
    esac
done

# Armar partes del comando
comando="find \"$ruta\""

if $usaNivel; then
    comando+=" -maxdepth $nivel"
fi

if $usaType; then
    comando+=" -type $tipo"
fi

if $usaDev; then
    comando+=" -xdev"
fi

#if $usaTiempo; then
#    comando+=" -atime -$tiempo"
#fi

if [[ "$usaFechaInicioModificacion" == "true" || "$usaFechaFinalModificacion" == "true" ]]; then

    if [[ "$usaFechaInicioModificacion" == "true" ]]; then
        comando+=" -mtime -$fechaInicioModificacion"
    fi

    if [[ "$usaFechaFinalModificacion" == "true" ]]; then
        comando+=" -mtime +$fechaFinalModificacion"
    fi

elif [[ "$usaFechaInicioAlta" == "true" || "$usaFechaFinalAlta" == "true" ]]; then

    if [[ "$usaFechaInicioAlta" == "true" ]]; then
        comando+=" -atime -$fechaInicioAlta"
    fi

    if [[ "$usaFechaFinalAlta" == "true" ]]; then
        comando+=" -atime +$fechaFinalAlta"
    fi
else
    if $usaTiempo; then
        comando+=" -atime -$tiempo"
    fi
fi



if $usaPermiso; then
    comando+=" -perm $permiso"
fi

if $usaEjecucion; then 
    comando+=" -executable"
fi

comando+=" -exec ls -l {} \; "
if $usaUsuario; then
    comando+=" -user $usuario"    
fi

if $usaGrupo; then
    comando+=" -group $grupo"
fi

# Ejecutar comando
if $usaRegex; then
    comando+=" | grep -E \"$regex\b\""
fi

if $usaSalida; then
    #echo "$comando > $salida"
    eval "$comando" > "$salida"
else
    #echo "$comando"
    eval "$comando"
fi
