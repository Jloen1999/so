#!/bin/bash

# Función para comprobar si un número es decimal
es_decimal() {
  # Patrón de expresión regular para un número decimal
  local patron="^[0-9]+([.][0-9]+)?$"
  local regex="[:digit:]"

  # Comprobar si el argumento coincide con el patrón
  if [[ $1 =~ $regex ]]; then
    echo "Es un número decimal."
  else
    echo "No es un número decimal."
  fi
}

# Ejemplo de uso
numero=2
es_decimal $numero
