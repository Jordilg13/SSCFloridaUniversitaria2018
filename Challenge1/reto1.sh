#!/bin/bash

IFS=$'\n'	# para que separe por lineas no por espacios
# definicion lista utilizada en control de errores y en op_3
meses=(enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre)
# control error retorna 1 si el campo mes contiene 

function op_1 { # operacion 1
	echo "EJEMPLO: 12 abril"
	read -p "Usuarios logueados el dia: " r_op1
	mes=$(echo $r_op1 | cut -d" " -f2)	# obtiene y asigna el mes a la variable mes
	#control errores
	if [[ ! " ${meses[@]} " =~ " ${mes} " ]]; then	# si el mes introducido no esta en la lista de meses fallara
		echo "$mes no es un mes valido."
	fi
	dia=$(echo $r_op1 | cut -d" " -f1)
	if [[ $dia -gt 31 ]] || [[ $dia -lt 1 ]]; then	#fallara si el dia introducido no es un numero o es menor que 1 o mayor que 31
		echo "El dia debe ser un numero entre 1 y 30."
		exit 1	#finaliza con codigo de error 1
	fi
	if [[ $(cat usuarios.txt | grep $mes | grep -w $dia | wc -l) -eq 0 ]]; then	# comprueba si se han logeado en la fecha introducida, si hay lo muestra, si no falla
		echo "Ningun usuario logueado el $dia del $mes."
	else
		cat usuarios.txt | grep $mes | grep -w $dia | uniq | cut -c 1-6	# muestra los nombres de usuario que han logueado en la fecha especificada
	fi
}
function op_2 {	# operacion 2
	read -p "Nombre del usuario: " r_op2
	if [[ $(cat usuarios.txt | grep -w $r_op2 | wc -l) -eq 0 ]]; then	# comprueba si el usuario ha logueado, si no falla. grep -w, para que no funcione por ejemplo si pones alc de alcaco
		echo "El usuario $r_op2 no se ha logueado."
	else
		#cat usuarios.txt | grep -w $r_op2 | sort | uniq | wc -l 	# muestra las veces que han logueado, uniq para que no cuente si ha logueado dos veces en un dia(alcaco 28 agosto)
		echo "El usuario se ha logueado $(cat usuarios.txt | grep -w $r_op2 | wc -l) veces." 	#muestra las veces que han logueado
	fi
}
function op_3 { 	#operacion 3
	# se estabelcen variables de control a 0
	ultima=0
	diamax=0
	read -p "Nombre del usuario: " r_op3
	if [[ $(cat usuarios.txt | grep -w $r_op3 | wc -l) -eq 0 ]]; then	# comprueba si el usuario ha logueado, si no falla
		echo "El usuario $r_op3 no se ha logueado."
	else
		for u in $(cat usuarios.txt | grep $r_op3); do 	# obtiene logs del usuario i los recorre
		#se obtiene y asigna el dia i el mes introducidos
		mes=$(echo $u | cut -d$'\t' -f3)
		dia=$(echo $u | cut -d$'\t' -f2)
		for num_mes in $(seq 0 11); do 	#se obtiene la posicion del mes en numero para poder compararla
			if [[ $mes == ${meses[$num_mes]} ]];then	#se compara el mes de la lista y el introducido, si son iguales se obtiene el indice 
				posicio=$num_mes
			fi
		done		
		if [[ $posicio -gt $ultima ]]; then	# el mes actual se va asignando si es mas grande (0-enero, 11-diciembre)
			ultima=$posicio
			dia_def=$dia 	# se asigna ara utilizarlo en la salida de la op3
		fi
		done	
		if [[ $(cat usuarios.txt | grep -w $r_op3 | grep ${meses[$ultima]} | wc -l) -eq 1 ]];then	# comprueba si solo ha logueado una vez, en ese caso esa es la fecha de su ultimo log
			echo "Ultima vez que se logueo: $dia_def ${meses[$ultima]}"
		else
			for s in $(cat usuarios.txt | grep -w $r_op3 | grep ${meses[$ultima]});do 	# si hay mas de un log del usuario en ese mes, se compara el dia
				diact=$(echo $s | cut -d$'\t' -f2)
				if [[ $diamax -lt $diact ]]; then 	
					diamax=$diact
				fi
			done
			echo "Ultima vez que se logueo: $diamax ${meses[$ultima]}"
		fi
	fi
}
# menu
echo "MENU RETO 1"
echo
echo "1.Operacion 1"
echo "2.Operacion 2"
echo "3.Operacion 3"
read -p "Elige una opcion: " o

case $o in 	# controla a que operacion acceder si no es 1, 2 o 3 falla
	1) op_1;;
	2) op_2;;
	3) op_3;;
	*) echo "Opcion invalida.";;
esac