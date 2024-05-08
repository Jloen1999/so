#!/bin/bash

source utils.sh
source analizeData.sh
source prediction.sh
source generateInform.sh
source help.sh
source colors.sh


# Declarar matriz asociativa global para almacenar las frecuencias
declare archivo_palabras
declare archivo_emails

declare -gA matriz_frecuencias
declare -gA matriz_tf_idf
declare -g archivo_tf_idf
declare -g archivo_frecuencias

declare -ig cols
declare -ig rows

#Inicializar filas y columnas
#declare -ig numEmails=5
#declare -ig numWords=5


# Menú Principal
while true; do
  # Dibujar la parte superior del cuadro del menú
  echo -e "${AMARILLO}+-----------------------------------+${RESET}"
  echo -e "${AMARILLO}|${AZUL}        MENÚ PRINCIPAL            ${AMARILLO}|${RESET}"

  # Mostramos el menu de opciones con colores y símbolos
  echo -e "${AMARILLO}|${RESET} ${VERDE}1.${RESET} Analisis de datos              ${AMARILLO}|${RESET}"
  echo -e "${AMARILLO}|${RESET} ${VERDE}2.${RESET} Predicción                     ${AMARILLO}|${RESET}"
  echo -e "${AMARILLO}|${RESET} ${VERDE}3.${RESET} Informes de resultados         ${AMARILLO}|${RESET}"
  echo -e "${AMARILLO}|${RESET} ${VERDE}4.${RESET} Ayuda                          ${AMARILLO}|${RESET}"
  echo -e "${AMARILLO}|${RESET} ${ROJO}5.${RESET} Salir                          ${AMARILLO}|${RESET}"

  # Dibujar la parte inferior del cuadro del menú
  echo -e "${AMARILLO}+-----------------------------------+${RESET}"

  read -p "Ingrese su opción: " opcion

  case $opcion in
    1) analisis_datos 1 ;;
    2) prediccion ;;
    3) informes_resultados ;;
    4) ayuda ;;
    5) salir ;;
    *) echo "Opción no válida";;
  esac
    
done
