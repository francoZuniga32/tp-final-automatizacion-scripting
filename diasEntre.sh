#!/bin/bash
# Fecha objetivo en formato yyyymmdd (por ejemplo: 20240101)
fecha_objetivo="$1"

# Convertir la fecha objetivo al formato que entiende date
fecha_formateada="${fecha_objetivo:0:4}-${fecha_objetivo:4:2}-${fecha_objetivo:6:2}"

# Obtener la fecha actual y convertir ambas a segundos desde Epoch
fecha_actual=$(date +%s)
fecha_objetivo_epoch=$(date -d "$fecha_formateada" +%s)

# Calcular la diferencia en segundos y convertir a días
diferencia_segundos=$((fecha_actual - fecha_objetivo_epoch))
diferencia_dias=$((diferencia_segundos / 86400))

echo "$diferencia_dias"
