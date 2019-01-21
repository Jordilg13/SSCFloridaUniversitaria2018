#!/bin/bash

function generar_baraja(){
	# se genera la baraja con los 4 palos i los 12 nuemeros por cada palo
	for palo in c d t p; do
		for num in $(seq 1 12); do
			baraja+=("$palo$num ")
		done
	done
}
function carta_aleatoria(){		# genera una carta aleatoria(palo+numero) que no se haya generado anteriormente
	if [[ ${#baraja[*]} -eq 0 ]]; then
		echo -e "Se han terminado las cartas de la baraja, se va a utilizar la baraja de nuevo.\nENTER para continuar."
		generar_baraja
		read
	fi

	rand=$((RANDOM % ${#baraja[*]}))	# random entre 0 i los elementos que contenga la baraja
	cartas+=("${baraja[$rand]}")
	unset baraja[$rand]	# se desasigna la carta para evitar repeticiones
	baraja=( "${baraja[@]}" )	# se re asigna para eliminar los indices vacios que deja el unset
}

function eleccion_crupier(){		# el crupier decide si se retira o no
	# Dado que no es especifica en la reglas del reto, supongo que el crupier no tiene unas reglas asignadas,
	# y se va a intentar simular el comportamiento de un jugador normal (p.e. puede probar suerte)

	# factores:
	# Si la diferencia entre las cartas del crupier y las del jugador es mayor de 8 el crupier se retira
	# si la diferencia esta entre 5 y 8, puede que el crupier se la juege, la posibilidad es mas alta cuanto menor sea la diferencia
	# si la diferencia esta entre 0 y 4 el crupier juega

	suma_jugador=$(( ${cartas_jugador[0]:1:2} + ${cartas_jugador[1]:1:2} + ${cartas_jugador[2]:1:2} ))	# se suman los valores de las cartas del jugador
	suma_crupier=$(( ${cartas_crupier[0]:1:2} + ${cartas_crupier[1]:1:2} ))
	echo 
	let diferencia=$suma_jugador-$suma_crupier
	if [[ $diferencia -lt 0 ]] || [[ $diferencia -le 4 ]]; then	# si el crupier tiene la suma mas alta o si la diferencia esta entre 0-4, juega
		return 1
	elif [[ $diferencia -gt 4 ]] || [[ $diferencia -le 8 ]]; then	# si esta entre 5-8, establece una probabilidad sobre 100, mas baja cuanto mas alta sea la diferencia
		case $diferencia in
			5) prob=40;;
			6) prob=30;;
			7) prob=20;;
			8) prob=10;;
		esac
		med_rand=$(( (RANDOM % 100) + 1 ))
		if [[ $med_rand -ge 1 ]] && [[ $med_rand -le $prob ]]; then 	# si el numero esta entre 0 y la probabilidad establecida juega, si no se retira
			return 1
		else
			return 0
		fi
	else
		return 0
	fi
}

function tablero(){
	clear
	echo "------------------------------------------------------------------"
	echo "Jugador: $nombre"
	echo "Saldo actual: $saldo"
	echo "Saldo apostado: $saldo_acumulado"
	echo "Tus cartas: ${cartas_jugador_tablero[*]}"
	echo
	echo "Cartas crupier: ${cartas_crupier_escondidas_tablero[*]}"
	echo "------------------------------------------------------------------"
	echo -e "\n\n"
}

clear
echo -e "INSTRUCCIONES\n"
echo "1.Comenzar almenos con 3 fichas."	#para poder hacer apuesta minima + doblar en el siguiente turno
echo "2.Juega contra el crupier."
echo "3.Si te quedas sin saldo pierdes."
echo "4.El saldo se guarda para todas las partidas hasta que dejes de jugar o te quedes sin saldo."
echo "5.La letra delante del numero en la carta indica el palo.(p-picas, t-treboles, d-diamantes y c-corazones)"
echo -e "6.Si no sigues jugando, pierdes esa partida y los puntos apostados hasta ese momento.\n"

generar_baraja
fin=0
read -p "Nombre: " nombre

# se comprueba que el saldo es un entero mayor que 3
until [[ $saldo_correcto -eq 1 ]]; do
	read -p "Saldo: " saldo
	if [[ $saldo =~ ^[0-9]+$ ]] && [[ $saldo -gt 2 ]];then
		saldo_correcto=1
	else
		echo "Error! Introduzca un numero mayor que 2."
	fi
done

while [[ $fin -eq 0 ]]; do # bucle del juego
	if [[ $saldo -eq 0 ]]; then	
		echo "Te has quedado sin saldo."
		break
	fi

	echo -e "\nSe van a repartir las cartas."
	read -p "ENTER para continuar."
	saldo_acumulado=0
	# se resetean variables
	unset cartas_crupier_escondidas_tablero
	unset cartas_jugador_tablero
	unset cartas_crupier	
	unset cartas
	unset cartas_jugador
	# se generan las cartas del crupier y del jugador, se llama a la funcion hasta que ambos tienen 3 cartas
	until [[ ${#cartas[*]} -eq 3 ]]; do
		carta_aleatoria
	done

	cartas_jugador=(${cartas[*]})
	unset cartas

	until [[ ${#cartas[*]} -eq 3 ]]; do
		carta_aleatoria
	done
	cartas_crupier=(${cartas[*]})
	cartas_crupier_escondidas=(? ? ?)
	pares=0
	impares=0
	tablero
	echo "Barajando..."
	sleep 3
	for i in $(seq 0 5); do
		if [[ $(($i % 2)) -eq 0 ]]; then
			cartas_jugador_tablero[$pares]=${cartas_jugador[$pares]}
			let pares+=1
		else
			cartas_crupier_escondidas_tablero[$impares]=${cartas_crupier_escondidas[$impares]}
			let impares+=1
		fi
		sleep 1.3
		tablero
		echo "Repartiendo..."
	done

	while [[ $fin_partida -eq 0 ]]; do 		# bucle de la partida actual
		saldo_acumulado=0
		let saldo-=1
		let saldo_acumulado+=1
		tablero
		echo -e "Se ha realizado la apuesta minima.\nSaldo actual: $saldo"
		read -p "Deseas continuar jugando esta partida?(y/n): " elec
		if [ "$elec" != "y" ] && [ "$elec" != "Y" ]; then
			echo "Has perdido :("
			fin_partida=1
			break 
		fi
		sube_apuesta=0	# se resetea cada partida
		until [[ $sube_apuesta -gt 0 ]] && [[ $sube_apuesta -le $saldo ]]; do 	# se repite la pregunta hasta que se introducce un numero correcto
			read -p "Cuanto quieres subir?(minimo 1 maximo $saldo):" sube_apuesta
			if [[ $sube_apuesta -gt $saldo ]]; then	# si la apuesta es mayor que el saldo que tienes
				read -p "No tienes tanto saldo, deseas apostar todo el que tienes?(y/n)" all_in
				if [ $all_in = "y" ] || [ $all_in = "Y" ];then
					let saldo_acumulado+=saldo
					sube_apuesta=$saldo
					saldo=0
					break
				fi
			else 	# si es menor 
				let saldo_acumulado+=sube_apuesta
				let saldo-=sube_apuesta
			fi
		done

		# se destapan las dos primeras cartas del crupier		
		cartas_crupier_escondidas_tablero[0]=${cartas_crupier[0]}
		cartas_crupier_escondidas_tablero[1]=${cartas_crupier[1]}
		tablero
		echo "El crupier ha destapado dos de sus cartas."
		echo "En la siguiente jugada debes doblar tu ultima apuesta."
		read -p "Deseas continuar jugando esta partida?(y/n): " elec
		if [ "$elec" != "y" ] && [ "$elec" != "Y" ]; then	# si no es y o Y te retiras y pierdes
			##clear
			echo "Has perdido :("
			fin_partida=1
			break 
		fi
		if [[ $saldo -lt $(( sube_apuesta * 2 )) ]]; then	# si no llegas a doblar la apuesta
			echo "No tienes suficiente para doblar la apuesta. Vas con todo."
			read -p "ENTER para continuar."
			let saldo_acumulado+=saldo
			saldo=0
		fi

		diferencia=0
		eleccion_crupier	# el crupier elige
		output_func=$?	# se recoje la salida de la funcion eleccion_crupier
		if [[ $output_func -eq 1 ]]; then	# si juega se descarta la ultima carta
			cartas_crupier_escondidas_tablero[2]=${cartas_crupier[2]}
			#clear
			echo "Has doblado tu apuesta."
			echo -e "La ultima carta del crupier era ${cartas_crupier[2]}\n"
			echo "Tu puntuacion: $suma_jugador (${cartas_jugador[*]})"
			let suma_crupier=suma_crupier+${cartas_crupier[2]:1:2}	# se suman los valores de las cartas del crupier
			echo "Puntuacion del crupier: $suma_crupier (${cartas_crupier[*]})"
			if [[ $suma_crupier -gt $suma_jugador ]]; then	# si el crupier suma mas que tu pierdes
				echo "Has perdido :("
			elif [[ $suma_crupier -lt $suma_jugador ]]; then
			 # si sumas mas que el crupier ganas el doble de lo apostado (lo que habias apostado + la apuesta del crupier)
				echo -e "Has ganado :)\nHas ganado $((saldo_acumulado * 2)) de saldo."
				let saldo+=$((saldo_acumulado * 2))
			else
				echo "Empate, recuperas tu saldo apostado."
				let saldo+=saldo_acumulado
			fi
		else 	# si se rinde ganas el doble (...)
			echo -e "El crupier se ha rendido.\nHas ganado $((saldo_acumulado * 2)) de saldo."
			let saldo+=$((saldo_acumulado * 2))
		fi
		fin_partida=1
		saldo_acumulado=0
	done
	read -p "Desea jugar otra partida?(y/n)" end_elec 	# y-se juega otra partida *-se acaba el juego
	if [ $end_elec != "y" ] && [ $end_elec != "Y" ]; then
			fin=1
	else
		fin_partida=0
	fi
done