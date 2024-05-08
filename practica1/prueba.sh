for (( j=2; j<cols; j++)); do
                termino="${matriz_frecuencias[0,$j]}"
                totalEmailsTerm=0
                for (( k=1; k<rows; k++)); do
                    frecuencia=${matriz_frecuencias[$k,$j]}
                    if [ "$frecuencia" -gt 0 ]; then
                        ((totalEmailsTerm++))
                    fi

                    matriz_tf_idf[$row,$col]="$frecuencia" # Almacenar las frecuencias
                    linea_resultados="$linea_resultados,$frecuencia"

                if [ "$totalWords" -ne 0 ]; then
                    tf=$(echo "$frecuencia / $totalWords" | bc -l)
                else
                    tf=0
                fi

                    
                done
                
                echo "El término $termino aparece en $totalEmailsTerm emails"
                
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

            done