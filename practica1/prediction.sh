#!/bin/bash

source cargarDatos.sh
source analizeData.sh
source utils.sh

declare -g archivo
declare -g palabras_clave
declare -g archivo_frecuencias

# Función para la Predicción
function prediccion() {
    echo -e "${AZUL}Iniciando Predicción...${RESET}"

    read -p "¿Usar datos recién analizados (s) o la matriz de análisis desde un fichero (c)? " eleccion

    if [[ $eleccion == "c" ]]; then

        read -p "Ingrese el nombre del archivo de frecuencias (.freq): " archivo_frecuencias

        if [[ -f "$archivo_frecuencias" ]]; then

            if [[ ! -s "$archivo_frecuencias" ]]; then

                echo -e "${AMARILLO}Archivo $archivo_frecuencias vacío${RESET}"

            else

                echo "Archivo: $archivo_frecuencias"
                archivo_tf_idf=`cut -d . -f 1 <<< "$archivo_frecuencias"`.tfidf

                if [[ -f "$archivo_tf_idf" ]]; then

                    echo "El fichero con la métrica TF_idf también se ha
realizado con anterioridad"

                    if [[ ! -s "$archivo_tf_idf" ]]; then

                        echo -e "${AMARILLO}Archivo $archivo_tf_idf vacío${RESET}"

                    else
                         
                        echo -n "¿Desea cargar todos los datos en las matrices correspondientes (s|n)? "
                        read conformidad

                        if [[ "$conformidad" == "s" ]]; then
                            # Cargar los datos en las matrices correspondientes
                            cargar_datos "$archivo_frecuencias" 1  

                            # Obtener numero de filas y columnas
                            rows=`awk 'END {print NR}' $archivo_frecuencias`
                            cols=`awk -F',' 'NR>1{print NF; exit}' $archivo_frecuencias`

                             # Mostrar matriz de frecuencias
                            echo -e "${AMARILLO}\t\t---------Matriz de frecuencias---------${RESET}"
                            for (( i=0; i<rows; i++ )); do
                                for (( j=0; j<cols; j++ )); do
                                    echo -ne "${AZUL}${matriz_frecuencias[$i,$j]},"
                                done
                                echo ""
                            done

                            cargar_datos "$archivo_tf_idf" 2

                            # Obtener numero de filas y columnas
                            rows=`awk 'END {print NR}' $archivo_tf_idf`
                            cols=`awk -F',' 'NR>1{print NF; exit}' $archivo_tf_idf`

                            # Mostrar matriz tf-idf
                            echo -e "${AMARILLO}\t\t---------Matriz TF-IDF---------${RESET}"
                            for (( i=0; i<rows; i++ )); do
                                for (( j=0; j<cols; j++ )); do
                                    echo -ne "${AZUL}${matriz_tf_idf[$i,$j]},"
                                done
                                echo ""
                            done
                            echo -e "${RESET}"
                            return

                        elif [[ "$conformidad" == "n" ]]; then
                            echo "Los datos no se cargarán en las matrices."
                        fi
                           
                    fi

                else
                    echo -e "${ROJO}No existe el archivo TF-IDF $archivo${RESET}"
                    analisis_datos 2    # Realizar análisis y predicción para TF-IDF
                    echo -e "${VERDE}Predicción completada.✅${RESET}"
                fi

                
                
                
              
            fi
            
        else

            echo "Archivo .freq no encontrado."
            return

        fi
    elif [[ $eleccion != "s" ]]; then
        echo "Opción no válida."
        return
    fi

    if [[ "$eleccion" == "s" ]]; then
        # Si se ha hecho el análisis recientemente. Procedemos a realizar la predicción.
        analisis_datos 2    # Realizar análisis y predicción para TF-IDF
        echo -e "${VERDE}Predicción completada.✅${RESET}"
    fi    
}