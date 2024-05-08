#!/bin/bash

source colors.sh

# Ya que vamos a hacer operaciones con el comando bc, instalaremos dicho paquete en caso de que no lo esté
function verifyPackage_bc() {
    
    # Comprobar conexion a internet
    ping -c1 8.8.8.8 > logs.txt &>1
    if (( $? != 0 )); then
        echo "${ROJO}❌No hay conexion a internet${RESET}"
    else
        dpkg -l | grep -q "bc"
        if (( $? == 0 )); then
            echo -e "${VERDE}✅El paquete bc está instalado${RESET}"
        else
            echo -e "${ROJO}❌No instalado${RESET}"
            echo "Instalando paquete bc..."
            sudo apt-get install bc > logs.txt &>1
            sleep  # retardo de 2 segundos
        fi
    fi
}


# Podemos reducir la cantidad de líneas. COMENTAR
function fileReduce() {
    ((numEmails++))
    ((numWords++))
    sed -i "${numEmails},\$d" "$archivo_emails" &>1
    sed -i "${numWords},\$d" "$archivo_palabras" &>1
}

# Verificar existencia de archivos de entrada
function verifyFile() {
    
    if [[ ! -f "$archivo_palabras" || ! -f "$archivo_emails" ]]; then
      echo -e "${ROJO}Error: Uno o más archivos de entrada no existen.${RESET}"
      return 1
    fi

    # Informar al usuario si el archivo de salida ya existe y será sobreescrito
    if [[ -f "$archivo" ]]; then
      echo "El archivo de salida $archivo ya existe y será sobreescrito."
    fi

}

# Salvar Frecuencias
function saveData() {
    local -i tipo=$1
    local -i row=1
    

    if [ "$tipo" -eq 1 ]; then
        echo -e "\t\t\t   ${VERDE}ID,Spam/HAM,Frecuencias${RESET}"
        while IFS='|' read -r id contenido spam_ham; do
            # Remover caracteres de nueva línea y espacios adicionales de spam_ham
            spam_ham=$(echo "$spam_ham" | tr -d '\n' | tr -d '\r' | tr -d '|' | xargs)
            if [[ -z "$id" || -z "$contenido" || -z "$spam_ham" ]]; then
                echo "Línea con formato incorrecto o vacía."
                continue
            fi

            # Procesar contenido
            contenido=$(echo "$contenido" | tr '[:upper:]' '[:lower:]')
            contenido=$(echo "$contenido" | tr -cd '[:alpha:] [:space:]') #Eliminar números y símbolos en el contenido del email

            # Almacenar ID y etiqueta spam/ham en la matriz
            matriz_frecuencias[$row,0]=$id
            matriz_frecuencias[$row,1]=$spam_ham
            
            # Iniciar la línea de resultados con ID y etiqueta spam/ham
            linea_resultados="$id,$spam_ham"

            totalWord=`echo "$contenido" |wc -w` # Obtener total de palabras que tiene el email

            # Almacenar el total de palabras que tiene cada email en un array que luego usaremos en la predicción
            totalWordEmail[$row]="$totalWord"

            local col=2
            # Iterar sobre cada termino
            for palabra in "${palabras_clave[@]}"; do

                # Convertir a minusculas y eliminar numeros y símbolos y puntuaciones.
                palabra=$(echo "$palabra" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alpha:] [:space:]')

                # Contar apariciones de la palabra clave en el contenido procesado
                freq=$(echo "$contenido" | grep -coi "$palabra")

                # Concatenar el conteo a la línea de resultados
                linea_resultados="$linea_resultados,$freq"

                matriz_frecuencias[$row,$col]=$freq    # Almacenar en matriz frecuencia de cada palabra en email

                ((col++))
            done

            # Escribir la línea de resultados en el archivo
            echo "$linea_resultados" >> "$archivo"
            # Mostrar la línea de resultados completa para depuración
            echo -e "\t\t\t\t${AZUL}$linea_resultados${RESET}"

            ((row++))
        done < "$archivo_emails"
    
    elif [ "$tipo" -eq 2 ]; then
        # ((rows--))
        for (( col=2; col<cols; row++ )); do
            id="${matriz_frecuencias[$row,0]}"
            spam_ham="${matriz_frecuencias[$row,1]}"
            echo -ne "ID: $id  Spam/Ham: $spam_ham\n"

            matriz_tf_idf[$row,0]=$id  # Almacenar ID
            matriz_tf_idf[$row,1]=$spam_ham   # Almacenar Spam/Ham
            
            linea_resultados="$id,$spam_ham"

            totalWords="${totalWordEmail[$row]}" # Obtener total de palabras que tiene el email
            # Calcular TF por cada término
            echo "==>Email $id tiene: $totalWords palabras"

            totalTF=0
            totalIDF=0
            totalEmailsTerm=0

            # Inicializar un array para almacenar términos procesados
            declare -A matriz=()
            echo "Cols: $cols"
            echo "CFils: $rows"

            for (( j=2; j<cols; j++)); do
                termino="${matriz_frecuencias[0,$j]}"
                totalEmailsTerm=0
                for (( k=1; k<rows; k++)); do
                    frecuencia=${matriz_frecuencias[$row,$k]}
                    echo "Frecuencia: $frecuencia"
                    if [ "$frecuencia" -gt 0 ]; then
                        ((totalEmailsTerm++))
                    fi

                    matriz_tf_idf[$k,$j]="$frecuencia" # Almacenar las frecuencias

                    if [ "$totalWords" -ne 0 ]; then
                        tf=$(echo "$frecuencia / $totalWords" | bc -l)
                    else
                        tf=0
                    fi
                
                
                done
                
                inea_resultados="$linea_resultados,$termino"
                
                echo -e "${AMARILLO}El término $termino aparece en $totalEmailsTerm emails${RESET}"
                
                
                # Formatear el resultado con dos decimales
                tf=$(printf "%.2f" "$tf")
                echo "==>TF: $tf"

                    
                totalTF=`echo "$totalTF+$tf"|bc -l`    # Acumular TF por cada término   
                #totalTF=`echo "scale=2; $totalTF+$tf" | bc`        
                totalTF=$(printf "%.2f" "$totalTF")
                echo "TF Acumulado: $totalTF"

                if [ "$totalEmailsTerm" -ne 0 ]; then
                    idf=$(echo "l($rows / $totalEmailsTerm) / l(10)" | bc -l)
                else
                    idf=0
                fi

                # Formatear el resultado con dos decimales
                idf=$(printf "%.2f" "$idf")
                echo "==>IDF: $idf"
                totalIDF=`echo "$totalIDF+$idf" | bc -l` # Acumular IDF por cada término  
                totalIDF=$(printf "%.2f" "$totalIDF")         
                echo "==>IDF Acumulado: $totalIDF"

                # Almacenar el término actual en el array de términos procesados
                terminos_procesados+=("$frecuencia")

            done

            # Almacenar total TF y total IDF en la matriz
            matriz_tf_idf[$row,$col]=$totalTF
            ((col++))
            matriz_tf_idf[$row,$col]=$totalIDF
            

            # Realizar la predicción basada en el valor medio de TF-IDF
            tf_idf=`echo "$totalTF * $totalIDF" | bc`
            tf_idf=$(printf "%.2f" "$tf_idf") 
            echo "==>TF-IDF: $tf_idf"        
            ((col++))
            matriz_tf_idf[$row,$col]=$tf_idf    # Almacenar indicador spam/ham

            umbral=0.3
            if [ $(echo "$tf_idf > $umbral" | bc) -eq 1 ]; then
                echo -e "${ROJO}El correo $id es probablemente SPAM (TF-IDF: $tf_idf).${RESET}"
            else
                echo -e "${VERDE}El correo $id es probablemente HAM (TF-IDF: $tf_idf).${RESET}"
            fi

            linea_resultados="$linea_resultados,$frecuencia,$totalTF,$totalIDF,$tf_idf"

            echo "$linea_resultados" >> $archivo

        done


    fi
}

# Función para Salir
# Función para imprimir un mensaje de cierre
function salir() {
  echo -e "${AZUL}Apagando el programa $emoji_apagar${RESET}"
  sleep 1
  echo -e "${AZUL}¡Programa finalizado con éxito!$emoji_apagar${RESET}"
}