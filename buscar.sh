#!/bin/bash

#funcion de utilidad

function ayuda(){
    echo "1: -t (f,d) para buscar archivos o directorios"
    echo "2: -x Limitar la busqueda en la direccion actual"
    echo "3: -o El resultado salga en un archivo directamente"
    exit 1  
}

function cortarFaltaOpcion() {
    if [[ -z "$1" ]]; then
        echo "Falta el parámetro para $2"
        ayuda
        exit 1
    fi
}

# agregamos las partes del comando

tiempo=0;
usaTiempo=false;

usaDev=false

usaType=false

usaRegex=false

usaSalida=false

if [[ $# -ge 1 ]]; then
    # esto obliga a tener si o si 1 parametros (la ruta, una opcion y un valor)

        if [[ -e "$1" ]]; then
            for ((i=2; i<=$#; i+=2)); do
                opcion="${!i}"              # accede al argumento en la posición i
                indice=$((i + 1))
                siguiente="${!indice}"     # accede a la opcion

                case "$opcion" in
                    "-d")
                        cortarFaltaOpcion "$siguiente" "la opción de -d"
                        usaTiempo=true;
                        dias=$((siguiente));
                        tiempo=$((tiempo+dias))
                    ;;
                    "-m")
                        cortarFaltaOpcion "$siguiente" "la opción de -m"
                        usaTiempo=true;
                        dias=$((30*siguiente));
                        tiempo=$((tiempo+dias))
                    ;;
                    "-a")
                        cortarFaltaOpcion "$siguiente" "la opción de -a"
                        usaTiempo=true;
                        dias=$((365*siguiente));
                        tiempo=$((tiempo+dias))
                    ;;
                    "-t")
                        cortarFaltaOpcion "$siguiente" "la opción de -t"
                        if [[ "$siguiente" == "f" || "$siguiente" == "d" ]]; then
                            usaType=true
                            tipo="$siguiente"
                        else
                            echo "Error: Tipo inválido. Usar 'f' para ficheros o 'd' para directorios."
                            exit 1
                        fi
                    ;;
                    "-R")
                        usaDev=true
                    ;;
                    "-O")
                        cortarFaltaOpcion "$siguiente" "la opción de -o"
                        usaSalida=true;
                        salida="$siguiente";
                    ;;
                    *) 
                        ayuda
                        exit 1
                     ;;
                esac
            done

            if ("$usaTiempo"); then
                time="-mtime +$tiempo ";
            else
                time="";
            fi

            if ("$usaType"); then
                tipo="-type $tipo ";
            else
                tipo="";
            fi

            if ("$usaDev"); then
                solo_actual="-xdev "
            else
                solo_actual="";
            fi


            # armamos la ejecucion
            echo "find $1 $tipo $solo_actual $time";
            
        fi
fi
