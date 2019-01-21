#!/bin/bash

# I - 1
# V - 5
# X - 10
# L - 50
# C - 100
# D - 500
# M - 1000

# Se lee de izquierda a derecha
# Menor a la izquierda resta
# Menor a la derecha suma
# Por tanto:
# I solo resta a V y X
# X solo resta a L y C
# C solo resta a D y M

function a_decimal() {
	total=0
	anterior=0
	cont=0
	#posib=(IVX XLC CDM)
	for i in $(seq $length -1 0)
	do
		if [[ $cont -eq 4 ]]; then
			echo "El numero introducido no es valido."
			exit 1
		fi
		letra_actual="${input_number:$i:1}"
		case $letra_actual in
			I|i)  actual=1 ;;
			V|v)  actual=5 ;;
			X|x)  actual=10 ;;
			L|l)  actual=50 ;;
			C|c)  actual=100 ;;
			D|d)  actual=500 ;;
			M|m)  actual=1000 ;;
		esac
		if [[ $actual -eq $anterior ]]; then
			let cont+=1
		else
			let cont=1
		fi

		if [[ $actual -lt $anterior ]]
		then
		   let total-=actual
		else
		   let total+=actual
		fi

		anterior=$actual
	done

	if [[ $total -gt 1999 ]]; then echo "Dato introducido erroneo, introduzca un numero del 1 al 1999.(en decimal o en romano)"; exit 1; fi
	echo "Introducido: $input_number"
	echo "Conversion: $total"


}

function a_romanos(){

	unidades=('' I II III IV V VI VII VIII IX)
	decenas=('' X XX XXX XL L LX LXX LXXX XC)
	centenas=('' C CC CCC CD D DC DCC DCCC CM)
	miles=('' M MM)
	#unidades
	numero_actual=${input_number:$length:1}
	uni=${unidades[$numero_actual]}

	if [[ $length -gt 0 ]]; then
		#decenas
		numero_actual=${input_number:$length-1:1}
		dec=${decenas[$numero_actual]}
	fi
	if [[ $length -gt 1 ]]; then
		#centenas
		numero_actual=${input_number:$length-2:1}
		cent=${centenas[$numero_actual]}
	fi
	if [[ $length -gt 2 ]]; then
		#miles
		numero_actual=${input_number:$length-3:1}
		mil=${miles[$numero_actual]}
	fi

	echo "Introducido: $input_number"
	echo "Conversion: $mil$cent$dec$uni"

}

input_number=$1
length=${#input_number}
let length=$length-1


if ! [[ -z $1 ]]; then
		if [[ $1 =~ ^[0-9]+$ ]] && [[ $1 -lt 2000 ]]; then
			a_romanos $1
		elif [[ $1 =~ [a-zA-Z] ]]; then
			a_decimal $1
		else
			echo "Dato introducido erroneo, introduzca un numero del 1 al 1999.(en decimal o en romano)"
		fi
fi
