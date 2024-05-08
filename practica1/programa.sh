#!/bin/bash
# Autor: Alfredo Mituy Okenve

#VARABLES GLOBALES A UTILIZAR
declare -a expresiones
declare -a correos
declare -a num_totales #Número total de palabras en cada correo
declare -A matriz_frecuencia
declare -A matriz_tf
declare -A matriz_tfidf
declare -a vec_idf #En cuántos correos aparecen los términos
fich_correo=""
fich_tfidf=""
M=0
N=0


#Aquí hacemos la ejecución del programa y lo primero es hacer el menú y que reciba la opción

while true
do
	echo -e "\t\033[4mMENÚ\033[0m"
	echo -e "\t1. Análisis de datos"
	echo -e "\t2. Predicción"
	echo -e "\t3. Informe de resultados"
	echo -e "\t4. Ayuda"
	echo -e "\t5. Salir"

	echo -n "Seleccione una opción del 1 al 5: "
	read opcion
	case $opcion in
		1)
			echo -e "\nHa seleccionado la opción 1, el análisis de datos\n"
			# Pedir los nombres de los archivos
            echo -n "Introduce el nombre del fichero de palabras: "
            read fich_pal
            #fich_pal="expresiones.txt"
            if test -z "$fich_pal"; then
                echo "No has introducido nada"
            elif test -f "$fich_pal"; then
                echo "El fichero $fich_pal existe"
            else
                echo "Este fichero NO existe"
            fi

            echo -n "Introduce el nombre del fichero de correos: "
            read fich_correo
            #fich_correo="Correos.txt"
            if test -z "$fich_correo"; then
                echo "No has introducido nada"
            elif test -f "$fich_correo"; then
                echo "El fichero $fich_correo existe"
            else
                echo "Este fichero NO existe"
            fi

            echo -n -e "\nIntroduce el nombre del fichero para almacenar el resultado del análisis: "
            read fich_alm
            #fich_alm="resultado"
            if test -z "$fich_alm"; then
                echo "No has introducido nada"
            else
                # Agregar la extensión ".freq" si no se proporciona
                if [[ $fich_alm != *".freq" ]]; then
                    fich_alm="$fich_alm.freq"
                    echo "El archivo $fich_alm ha sido agregado"
                fi
                if test -f "$fich_alm"; then
                    echo "El archivo de resultado ya existe."
                fi
            fi
            
            echo -e "\nAnalizando...\n"
            
            # Declarar matrices y vectores
            while IFS= read -r linea; do
                expresiones+=("$(echo "$linea" | sed 's/[^a-zA-Z ]/ /g' | awk '{print tolower($0)}')")
            done < "$fich_pal"

            M=${#expresiones[*]}
                
            fila=1
            while IFS="|" read -r id linea et;do
                #Limpiamos el correo para trabajar con él
                correos+=("$linea")
                correo_limpio=$(echo "$linea" | sed 's/[^a-zA-Z ]/ /g' | awk '{print tolower($0)}') #Mirar si puedo usar una de las funciones dadas
                    
                #Ahora inicializo la matriz
                matriz_frecuencia["$fila,1"]=$id
                et=$(echo "$et" | cut -c1)
                matriz_frecuencia["$fila,2"]=$et
                    
                num_palabras=$(echo "$correo_limpio" | wc -w)
                num_totales["$fila"]=$num_palabras
                N=$((N+1))

                #Contamos la frecuencia de expresiones en el correo
                n=1
                for ((col = 3; col <= M + 2; col++)); do
                    expresion="${expresiones[$((col - 3))]}"
                    n=$((n+1))
                    frecuencia=$(echo "$correo_limpio" | awk -v var="$expresion" '{count += gsub(tolower(var), "", $0)} END {print count}')
                    matriz_frecuencia["$fila,$col"]=$frecuencia
                done
                    
                fila=$((fila + 1))
            done<"$fich_correo"
                
            #Imprimiendo primeras filas y columnas de la matriz de frecuencia
            echo "Matriz de frecuencia:"
            for ((i=1;i<=10;i++));do
                for ((j=1;j<=12;j++));do
                    echo -n "${matriz_frecuencia[$i,$j]} "
                done
                echo
            done
            cols=$((M+2))
            echo -e "\nNumero de filas: $N; Numero de columnas: $cols"
            
            #Guardamos la matriz en el fichero de almacenamiento
            >"$fich_alm"  # Limpiar o crear el archivo
            for ((i=1;i<=N;i++));do
                for ((j=1;j<=cols;j++));do
                    echo -n "${matriz_frecuencia[$i,$j]} " >> "$fich_alm"
                done
                echo >> "$fich_alm"
            done

            echo -e "\nEl análisis se ha completado y se ha guardado en $fich_alm\n\n"
			;;
		2)
			echo -e "\nHa seleccionado la opción 2, la predicción\n"
			while true;do
                echo "¿Ha realizado recientemente el análisis de datos o desea cargar la matriz de análisis desde un fichero?:"
                echo -e "\t1. Análisis recientemente hecho"
                echo -e "\t2. Cargar matriz de análisis desde fichero"
                read -p "Respuesta:" res

                if [ $res -eq 1 ]; then
                    # Lógica para el caso 1: Análisis recientemente hecho
                    echo -e "\nRealizando análisis de TF-IDF..."
                    M=$((M+2))
                    echo "Numero de filas: $N; Numero de columnas: $M"
                    tf=0
                    suma=0
                    for ((k=1;k<=M;k++)); do
                        vec_idf[$k]=0
                    done
                    vec_idf[1]=X
                    vec_idf[2]=X
                    idf=0
                    num_correos=$N
                    echo "Num correos: $num_correos"

                    #Esto nos servirá para calcular los TF y almacenar las primeras variables para el IDF
                    echo "Calculando los TF...."
                    for ((i=1;i<=N;i++));do
                        nc=${num_totales[i]} #El número de palabras que hay en el correo
                        matriz_tf["$i,1"]=$i
                        matriz_tf["$i,2"]="X"

                        for ((j=3;j<=M;j++));do
                            nv=${matriz_frecuencia["$i,$j"]}
                            tf=$(echo "scale=4; $nv / $nc" | bc -l)
                            matriz_tf["$i,$j"]=$tf

                            if ((nv>0)); then
                                vec_idf[$j]=$((vec_idf[$j]+1))
                            fi
                        done
                    done

                    for ((i=1;i<=10;i++));do
                        for ((j=1;j<=12;j++));do
                            echo -n "${matriz_tf[$i,$j]} "
                        done
                        echo
                    done

                    #Aquí hacemos el cálculo y lo metemos en la matriz TF-IDF
                    v_idf=(${vec_idf[@]})
                    t=${#v_idf[*]}
                    echo "Tamano: $t"
                    for ((i=1;i<=N;i++));do
                        matriz_tfidf["$i,1"]=$i  # Esto establece el valor de la primera columna una vez por fila
                        matriz_tfidf["$i,2"]="X"
                        tfidf=0
                        b=$i
                        for ((j=3;j<=M;j++));do
                            nu=$((j-1))
                            nIdf=${v_idf[$nu]}
                            if (($nIdf > 0)); then
                                idf=$(echo "scale=4; l($num_correos / $nIdf) / l(10)" | bc -l)
                            else
                                idf=0
                            fi
                            tf=${matriz_tf["$i,$j"]}
                            tfidf=$(echo "scale=4; $tf * $idf" | bc -l)
                            matriz_tfidf[$b,$j]=$tfidf
                        done
                    done

                    #--------------------------------------------------------
                    # DEFENSA. Valor de corte para calificar como spam
                    read -p "Seleccionar valor de corte para calificar como Spam: " valor_corte

                    #VAMOS A PONER SI ES SPAM O HAM
                    # Recorremos cada fila (correo) y calculamos el TF-IDF promedio
                    for ((correo=1; correo<=N; correo++)); do
                        suma=0
                        num_terminos=0

                        for ((termino=3; termino<=M; termino++)); do
                            tfidf=${matriz_tfidf["$correo,$termino"]}
                            if (( $(echo "$tfidf > 0" | bc -l) )); then
                                suma=$(echo "$suma + $tfidf" | bc -l)
                                num_terminos=$((num_terminos + 1))
                            fi
                        done

                        if ((num_terminos > 0)); then
                            tfidf_promedio=$(echo "$suma / $num_terminos" | bc -l)
                        else
                            tfidf_promedio=0
                        fi

                        # Colocamos 1 o 0 en la segunda columna de acuerdo con el valor de corte
                        if (( $(echo "$tfidf_promedio > $valor_corte" | bc -l) )); then
                            matriz_tfidf["$correo,2"]=1
                        else
                            matriz_tfidf["$correo,2"]=0
                        fi
                    done
                    #--------------------------------------------------------

                    #Imprimimos y mostramos por pantalla la matriz TF-IDF
                    echo "Matriz TF-IDF:"
                    for ((i=1;i<=10;i++));do
                        for ((j=1;j<=12;j++));do
                            echo -n "${matriz_tfidf[$i,$j]} "
                        done
                        echo
                    done

                    #Almacenamos la matriz TF-IDF
                    fich_tfidf="${fich_alm%.freq}.tfidf"
                    >"$fich_tfidf"
                    for ((fila = 1; fila <= N; fila++)); do
                        for ((col = 1; col <= M; col++)); do
                            echo -n "${matriz_tfidf["$fila,$col"]} " >> "$fich_tfidf"
                        done
                        echo >> "$fich_tfidf"
                    done

                    echo "Análisis de TF-IDF completado y guardado en $fich_tfidf."
                    break
                elif [ $res -eq 2 ]; then
                    # Lógica para el caso 2: Cargar matriz de análisis desde fichero
                    echo -n "Ingrese el nombre del archivo de matriz de frecuencia (.freq): "
                    read fich_freq
                    
                    if [ -f "$fich_freq" ]; then
                        # El archivo existe, cargar datos en la matriz de frecuencia
                        # Puedes usar un comando como 'cat' o 'while read' para cargar los datos en la matriz

                        # Comprueba si también existe el archivo .tfidf
                        fich_tfidf="${fich_freq%.*}.tfidf"  # Genera el nombre del archivo .tfidf
                        if [ -f "$fich_tfidf" ]; then
                            echo "El archivo $fich_tfidf también existe."
                            echo -n "¿Desea cargar todos los datos en las matrices correspondientes? (Si/No): "
                            read conformidad

                            if [ "$conformidad" = "Si" ] || [ "$conformidad" = "si" ]; then
                                # Cargar los datos en las matrices correspondientes
                                while read -r linea; do
                                    IFS=' ' read -ra elementos <<< "$linea"  # Dividir la línea en elementos
                                    id_correo="${elementos[0]}"
                                    t=$((${#elementos[@]}))
                                    for ((i=0; i<$t; i++)); do
                                        m=${elementos[i]}
                                        echo "m: $m"
                                        matriz_frecuencia["$id_correo,$i"]=$m
                                        echo "mFrec[$id_correo,$i]: ${matriz_frecuencia[$id_correo,$i]}"
                                    done
                                done < "$fich_freq"
                                while read -r linea; do
                                    IFS=' ' read -ra elementos <<< "$linea"  # Dividir la línea en elementos
                                    id_correo="${elementos[0]}"
                                    t=$((${#elementos[@]}+2))
                                    for ((i=0; i<$t; i++)); do
                                        matriz_tfidf["$id_correo,$i"]="${elementos[i]}"
                                    done
                                done < "$fich_tfidf"
                                echo "Datos cargados en las matrices correspondientes."
                                echo "Matriz Frecuencia:"
                                for ((i=1;i<=10;i++));do
                                    for ((j=1;j<=12;j++));do
                                        echo -n "${matriz_frecuencia[$i,$j]} "
                                    done
                                    echo
                                done
                                echo "Matriz TF-IDF:"
                                for ((i=1;i<=10;i++));do
                                    for ((j=1;j<=12;j++));do
                                        echo -n "${matriz_tfidf[$i,$j]} "
                                    done
                                    echo
                                done
                            else
                                echo "Los datos no se cargarán en las matrices."
                            fi
                        else
                            echo "El archivo $fich_tfidf no existe."
                            while read -r linea; do
                                IFS=' ' read -ra elementos <<< "$linea"  # Dividir la línea en elementos
                                id_correo="${elementos[0]}"
                                t=$((${#elementos[@]}+2))
                                for ((i=1; i<=$t; i++)); do
                                    matriz_frecuencia["$id_correo,$i"]="${elementos[i]}"
                                done
                            done < "$fich_freq"

                            echo "Matriz Frecuencia:"
                                for ((i=1;i<=10;i++));do
                                    for ((j=1;j<=12;j++));do
                                        echo -n "${matriz_frecuencia[$i,$j]} "
                                    done
                                    echo
                                done

                            echo "Calculando los TF...."
                            for ((i=1;i<=N;i++));do
                                nc=${num_totales[i]} #El número de palabras que hay en el correo

                                for ((j=3;j<=M;j++));do
                                    nv=${matriz_frecuencia["$i,$j"]}
                                    tf=$(echo "scale=4; $nv / $nc" | bc -l)
                                    matriz_tf["$i,$j"]=$tf

                                    if ((nv>0)); then
                                        vec_idf[$j]=$((vec_idf[$j]+1))
                                    fi
                                done
                            done

                            for ((i=1;i<=10;i++));do
                                for ((j=1;j<=12;j++));do
                                    echo -n "${matriz_tf[$i,$j]} "
                                done
                                echo
                            done

                            #Aquí hacemos el cálculo y lo metemos en la matriz TF-IDF
                            v_idf=(${vec_idf[@]})
                            t=${#v_idf[*]}
                            echo "Tamano: $t"
                            for ((i=1;i<=N;i++));do
                                matriz_tfidf["$i,1"]=$i  # Esto establece el valor de la primera columna una vez por fila
                                matriz_tfidf["$i,2"]="X"
                                tfidf=0
                                b=$i
                                for ((j=3;j<=M;j++));do
                                    nu=$((j-1))
                                    nIdf=${v_idf[$nu]}
                                    if (($nIdf > 0)); then
                                        idf=$(echo "scale=4; l($num_correos / $nIdf) / l(10)" | bc -l)
                                    else
                                        idf=0
                                    fi
                                    tf=${matriz_tf["$i,$j"]}
                                    tfidf=$(echo "scale=4; $tf * $idf" | bc -l)
                                    matriz_tfidf[$b,$j]=$tfidf
                                done
                            done

                            #------------------------------------------------
                            # DEFENSA. Valor de corte para calificar como spam
                            read -p "Seleccionar valor de corte para calificar como Spam: " valor_corte

                            #VAMOS A PONER SI ES SPAM O HAM
                            # Recorremos cada fila (correo) y calculamos el TF-IDF promedio
                            for ((correo=1; correo<=N; correo++)); do
                                suma=0
                                num_terminos=0

                                for ((termino=3; termino<=M; termino++)); do
                                    tfidf=${matriz_tfidf["$correo,$termino"]}
                                    if ((tfidf > 0)); then
                                        suma=$(echo "$suma + $tfidf" | bc -l)
                                        num_terminos=$((num_terminos + 1))
                                    fi
                                done

                                if ((num_terminos > 0)); then
                                    tfidf_promedio=$(echo "$suma / $num_terminos" | bc -l)
                                else
                                    tfidf_promedio=0
                                fi

                                # Colocamos 1 o 0 en la segunda columna de acuerdo con el valor de corte
                                if (( $(echo "$tfidf_promedio > $valor_corte" | bc -l) )); then
                                    matriz_tfidf["$correo,2"]=1
                                else>
                                    matriz_tfidf["$correo,2"]=0
                                fi
                            done
                            #------------------------------------------------

                            #Imprimimos y mostramos por pantalla la matriz TF-IDF
                            echo "Matriz TF-IDF:"
                            for ((i=1;i<=10;i++));do
                                for ((j=1;j<=12;j++));do
                                    echo -n "${matriz_tfidf[$i,$j]} "
                                done
                                echo
                            done

                            #Almacenamos la matriz TF-IDF
                            fich_tfidf="${fich_alm%.freq}.tfidf"
                            >"$fich_tfidf"
                            for ((fila = 1; fila <= N; fila++)); do
                                for ((col = 1; col <= M; col++)); do
                                    echo -n "${matriz_tfidf["$fila,$col"]} " >> "$fich_tfidf"
                                done
                                echo >> "$fich_tfidf"
                            done

                            echo "Análisis de TF-IDF completado y guardado en $fich_tfidf."
                        fi
                        
                    else
                        echo "El archivo $fich_freq no existe. Intente nuevamente."
                    fi

                    break
                else
                    echo "Por favor, seleccione una opción válida (1 o 2)."
                fi
            done
			;;
		3)
			echo -e "\nHa seleccionado la opción 3, el informe de resultados"
			while true; do
                echo -e "\nSeleccione el tipo de informe que desea generar:"
                echo "1. Informe de términos en correos electrónicos"
                echo "2. Dado un término particular, mostrar correos electrónicos donde aparecen"
                echo "3. Dado el ID de un correo electrónico, mostrar número de términos analizados que aparecen"
                echo "4. Volver al menú principal"
                echo -n "Opción: "
                read opcion

                case $opcion in
                    1)
                        # Generar informe de términos en correos electrónicos
                        echo "Informe de términos en correos electrónicos:"

                        nums=${#expresiones[*]}
                        # Recorre la matriz y cuenta la frecuencia de cada término en cada correo
                        echo "Expresión | Nº de correos en los que aparece"
                        echo "-----------------------------------------------"

                        for ((l=0;l<$nums;l++)); do
                            exp=${expresiones[$l]}
                            k=$((l+3))
                            apar=${vec_idf[$k]}
                            #Muestro la tabla
                            printf "%-15s | %-4s\n" "$exp" "$apar"
                        done
                        
                        ;;
                    2)
                        # Generar informe de correos electrónicos por término
                        echo "Informe de correos electrónicos por término:"
                        # Solicitar al usuario el término a buscar
                        echo -n "Ingrese el término que desea buscar:"
                        read termino
                        termino=$(echo "$termino" | sed 's/[^a-zA-Z ]/ /g' | awk '{print tolower($0)}')
                        encontrado=false
                        # Recorre la matriz y muestra los correos que contienen el término
                        c=0
                        while [ $c -lt $M ] && [ $encontrado = false ]; do
                            exp=${expresiones[$c]}
                            if [ "$termino" = "$exp" ]; then
                                #Encabezado
                                echo "Expresión | ID Correo | Correo (50 caracteres)"
                                echo "-------------------------------------------------"

                                for ((l=0;l<N;l++)); do
                                    corr=${correos[l]}
                                    corr=$(echo "$corr" | sed 's/[^a-zA-Z ]/ /g' | awk '{print tolower($0)}')
                                    if [[ $corr == *"$termino"* ]]; then
                                        corr=$(echo $corr | cut -c 1-50)
                                        s=$((l+1))
                                        #Mostrando tabla
                                        printf "%-15s | %-4s | %-55s\n" "$termino" "$s" "$corr"
                                    fi
                                done

                                encontrado=true
                            fi
                            c=$((c+1))
                        done
                        if [ "$encontrado" = false ]; then
                            echo "No se encontraron correos que contengan el término '$termino'."
                        fi
                        ;;
                    3)
                        # Generar informe de términos en un correo electrónico
                        echo "Informe de términos en un correo electrónico:"
                        # Solicitar al usuario el identificador de correo electrónico
                        read -p "Ingrese el identificador del correo electrónico: " id_correo

                        #Datos
                        num_term=0
                        num_analizados=${#expresiones[*]}
                        for ((t=3;t<=M;t++)); do
                            x=${matriz_frecuencia["$id_correo,$t"]}
                            if [ $x -gt 0 ]; then
                                num_term=$((num_term+1))
                            fi
                        done

                        # Encabezados
                        echo "ID Correo | Nº términos aparecidos | Nº términos analizados"
                        echo "-----------------------------------------------------------"
                        
                        # Busca el correo por su identificador y muestra los términos presentes
                        printf "%-10s | %-4s | %-15s\n" "$id_correo" "$num_term" "$num_analizados"
                        ;;
                    4)
                        break
                        ;;
                    *)
                        echo "Opción no válida. Por favor, seleccione una opción válida."
                        ;;
                esac
            done
			;;
		4)
			echo -e "\nHa seleccionado la opción 4, la ayuda\n"
			echo -e "\033[4mAyuda\033[0m"
            echo "Bienvenido a la aplicación de análisis de correos electrónicos."
            echo "Esta aplicación permite analizar correos electrónicos en busca de contenido potencialmente peligroso y clasificarlos como spam o ham."
            echo
            echo "Opciones disponibles:"
            echo "1. Análisis de datos: Realiza un análisis de los correos electrónicos y términos proporcionados."
            echo "2. Predicción: Realiza predicciones sobre si un correo es spam o ham."
            echo "3. Informes de resultados: Genera informes basados en los datos analizados."
            echo "4. Ayuda: Muestra esta información de ayuda."
            echo "5. Salir: Finaliza la aplicación."
            echo
            echo "Para utilizar una opción, ingrese el número correspondiente en el menú principal."
            echo
            echo "Ejemplos de uso:"
            echo "  - Para realizar un análisis de datos, seleccione la opción 1 y siga las instrucciones. Una vez realizado el análisis no haga otro hasta haber reiniciado el programa, sale y vuelve a entrar, es para preservar los datos"
            echo "  - Para realizar predicciones, seleccione la opción 2 después de completar el análisis. En caso de querer cargar los datos del fichero y no está la matriz TF-IDF es imprescindible que el análisis de datos sea hecho de nuevo"
            echo "  - Para generar informes, seleccione la opción 3 y elija el tipo de informe que desea. Es necesario realizar primero el análisis de datos y la predicción para obtener el informe"
            echo "  - Si necesita ayuda en cualquier momento, seleccione la opción 4."
            echo "  - Para salir de la aplicación, seleccione la opción 5."
            echo
            echo "¡Disfrute utilizando el programa y asegure sus correos comprobando si son SPAM!"
            echo -e "FIN DE AYUDA\n\n"
			;;
		5)
			echo -e "\nHa seleccionado la opción 5, salir\n"
			echo "Saliendo del programa..."
	        exit 0
			;;
		*)
			echo -e "Ninguna de las opciones seleccionadas es correcta, marque de nuevo un número del 1 al 5"
			;;
	esac
done
