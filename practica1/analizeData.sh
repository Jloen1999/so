#!/bin/bash

source utils.sh
source colors.sh

declare -a totalWordEmail

# Función para el Análisis de Datos
function analisis_datos() {
  local -i tipo=$1
  local -i exist=0

  if [ "$tipo" -eq 1 ]; then
    echo -e "${AZUL}Iniciando Análisis de Datos de Frecuencias...🪁${RESET}"

    # Pedir al usuario los nombres de los archivos
    read -p "==>Ingrese el nombre del archivo de palabras clave (Fraud_word.txt): " archivo_palabras
    read -p "==>Ingrese el nombre del archivo de correos electrónicos (Emails.txt): " archivo_emails
    read -p "==>Ingrese el nombre del archivo de salida para los resultados: " archivo

    # Verificar existencia de archivos de entrada
    verifyFile
    exist=$?


    if [ "$exist" -eq 0 ]; then
      # Podemos reducir la cantidad de líneas. COMENTAR
      # fileReduce

      archivo="$archivo.freq" # Poner la extensión freq
      
      # Procesamiento de los archivos
      echo -e "${AZUL}Procesando🛠...${RESET}"

      # Convertir palabras clave a minúsculas y almacenar en un array

      readarray -t palabras_clave < <(tr '[:upper:]' '[:lower:]' < "$archivo_palabras")

      # Preparar archivo de salida
      echo -n "Id,spam/ham," > "$archivo"
      matriz_frecuencias[0,0]="Id"
      matriz_frecuencias[0,1]="Spam"

      cont=2
      for word in "${palabras_clave[@]}"; do
        echo -n "$word," >> "$archivo"
        matriz_frecuencias[0,$cont]="$word"
        ((cont++))
      done

      # Eliminar la última coma
      sed -i 's/,$//' "$archivo"
      echo "" >> "$archivo"

      echo "Análisis de Datos completado. Resultados guardados en $archivo"
      # Salvar Frecuencias 
      saveData 1


      # Obtener numero de filas y columnas
      rows=`awk 'END {print NR}' $archivo`
      cols=`awk -F',' 'NR>1{print NF; exit}' $archivo`

    fi

  elif [ "$tipo" -eq 2 ]; then

    echo -e "\n${AZUL}Realizando análisis de TF-IDF🪁...${RESET}"
    # Crear archivo .tfidf
    echo "Archivo: $archivo"
    archivo=`cut -d . -f 1 <<< "$archivo"`.tfidf
    if [ "$?" -eq 0 ]; then
      echo "Creando archivo .tfidf...⛏"
      echo "Archivo creado✔"
    else
      echo "Cuidado⚠, no has realizado un análisis previo"
      return
    fi
    

    # Usar matriz de Frecuencias para almacenar el encabezado.
    # Preparar archivo de salida
    echo -n "Id,spam/ham," > "$archivo"
    matriz_tf_idf[0,0]="Id"
    matriz_tf_idf[0,1]="Spam"

    cont=2
    for word in "${palabras_clave[@]}"; do
      echo -n "$word," >> "$archivo"
      matriz_tf_idf[0,$cont]="$word"
      ((cont++))
    done

    echo -ne "TF,IDF,TF-IDF\n" >> "$archivo"
    matriz_tf_idf[0,$cont]="TF"
    ((cont++))
    matriz_tf_idf[0,$cont]="IDF"
    ((cont++))
    matriz_tf_idf[0,$cont]="TF-IDF"

    echo "Análisis de Datos completado. Resultados guardados en $archivo"
    # Salvar TF-IDF
    saveData 2

  fi


}
