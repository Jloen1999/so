#!/bin/bash

# Función para los Informes de Resultados
function informes_resultados() {
    echo -e "\nINFORME DE resultados"
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
                # Obtener numero de filas y columnas
                echo "Total de filas: $rows"
                echo "Total de columnas: $cols"

                
                    for (( j=2; j<cols; j++)); do
                        termino="${matriz_frecuencias[0,$j]}"
                        totalAp=0
                        for (( k=1; k<rows; k++)); do
                            nv=${matriz_frecuencias[$k,$j]}
                            if [ "$nv" -gt 0 ]; then
                                ((totalAp++))
                            fi
                        done
                         #Muestro la tabla
                        printf "%-15s | %-4s\n" "$termino" "$totalAp"
                    done
                    

               
                
                ;;
            2)
                # Generar informe de correos electrónicos por término
                echo "Informe de correos electrónicos por término:"
                # Solicitar al usuario el término a buscar
                echo -n "Ingrese el término que desea buscar:"
                read termino
                
                
                ;;
            3)
                # Generar informe de términos en un correo electrónico
                echo "Informe de términos en un correo electrónico:"
                # Solicitar al usuario el identificador de correo electrónico
                read -p "Ingrese el identificador del correo electrónico: " id_correo

                
                # Encabezados
                echo "ID Correo | Nº términos aparecidos | Nº términos analizados"
                echo "-----------------------------------------------------------"
                
                # Busca el correo por su identificador y muestra los términos presentes
                #printf "%-10s | %-4s | %-15s\n" "$id_correo" "$num_term" "$num_analizados"
                ;;
            4)
                source p1.sh
                ;;
            *)
                echo "Opción no válida. Por favor, seleccione una opción válida."
                ;;
        esac
    done
}