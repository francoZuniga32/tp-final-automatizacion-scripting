#!/bin/bash

comando="find ";

mi_funcion() {
    echo "Hola mundo"
}

for ((i=0; i<$#; i++)); do
    opcion="${!i}"      # accede al argumento en la posición i
    siguiente="${!((i+1))}"  # accede al siguiente argumento

    if [ "$opcion" = "-d" ]; then
        comando+=$(mi_funcion)
    elif ["$opcion" = "-a" ]
        echo "$opcion no es un directorio"
    fi
done
