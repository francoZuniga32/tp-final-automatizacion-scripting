# Trabajo practico Automatizacion y Scripting

Es muy común la búsqueda de archivos y sobre todo scripts que hacen uso de find, grep y ls , de forma muy usual. En nuestras tareas como administradores nos encontramos muchas veces buscando archivos que sigan un cierto patrón, permisos, y otros datos adicionales que no son útiles en nuestra tarea. Pero cuando estamos programando o usando la línea de comandos queremos evitar realizar muchas operaciones mentales para poder formar una linea coherente para bash.
Ej
```bash
find / -mtime 2 -type f -user root -perm 777 | grep -E ‘*.sh’  
```

En la línea anterior buscamos archivos que hayan sido modificados hace 2 días exactos con los permisos 777 y siguiendo el patrón específico.
Pero qué pasa si queremos que sea un archivo hace 2 años y 2 meses tendremos que hacer las cuentas de cuántos días representaría eso.
Otra cosa que se nos hace un poco molesto de hacer es buscar por una fecha un archivo creado o modificado o buscar un archivo que ha sido creado y  modificado entre dos fechas.
Además es común usar el comando ls -l para buscar información sobre los archivos buscados. 
Este script 

## Opciones del script

buscar-ls.sh recibe los siguientes parametros
`./buscar-ls.sh <ruta> <opciones>`

Opciones:
```
  -t (f|d)     Buscar archivos (f) o directorios (d)
  -x          Limitar la búsqueda al sistema de archivos actual
  -o <archivo> Guardar salida en un archivo
  -d <n>       Buscar archivos modificados hace más de n días
  -m <n>       Buscar archivos modificados hace más de n meses
  -a <n>       Buscar archivos modificados hace más de n años
  -u <usuario>  Buscar archivos por usuario o ID de usuario
  -g <grupo>    Buscar archivos por grupo o ID de grupo
  -e <tipo de archivo>  Buscar archivos por extencion de archivo (por ejemplo .jpg)
  -n <n>       Buscar archivos o directorios en n niveles de profundidad
  -h imprime la ayuda
  -modificacionfechainicio yyyymmdd  Busca archivos que hayan sido modificados desde la fecha ingresada en adelante
  -modificacionfechafinal yyyymmdd   Busca archivos que hayan sido modificados antes de la fecha ingresada
  -altafechainicio yyyymmdd          Busca archivos que hayan sido creados desde la fecha ingresada en adelante
  -altafechafinal yyyymmdd           Busca archivos que hayan sido creados antes de la fecha ingresada
```
tambien se puede ejecutar `./buscar-ls.sh -h` para obtener un listado de las opciones.
