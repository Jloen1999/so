#!/bin/bash

source colors.sh

cargar_datos() {
  local archivo=$1
  local tipoFichero=$2
  # Declarar la matriz asociativa
  declare -A matriz


  row=0
  # Leer el archivo línea por línea
  while IFS=, read -ra line; do
    # Iterar sobre los elementos de la línea
    col=0
    for valor in "${line[@]}"; do
      # Almacenar el valor en la matriz asociativa
      matriz[$row,$col]=$valor

      # Incrementar el contador de columna
      ((col++))
    done
    
    ((row++))
  done < "$archivo"

  if [ "$tipoFichero" -eq 1 ]; then
    
    echo -e "${AZUL}Cargando datos de frecuencias desde $archivo...${RESET}"
    for clave in "${!matriz[@]}"; do
      matriz_frecuencias["$clave"]="${matriz[$clave]}"
    done
    
  elif [ "$tipoFichero" -eq 2 ]; then

    echo -e "${AZUL}Cargando datos tf_idf desde $archivo...${RESET}"
    for clave in "${!matriz[@]}"; do
      matriz_tf_idf["$clave"]="${matriz[$clave]}"
    done

  fi

  rows=row
  cols=col
    
}
