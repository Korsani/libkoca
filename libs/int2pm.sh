# Return the number converted in +/- scale
function int2pm { # return +, ++, +++ (or -). <val> <base>
	local val="$1"
	local base="$2"
	local SCALE=3
	if ! ( [[ $base =~ ^[0-9]+$ ]] && [[ $val =~ ^-?[0-9]+$ ]] )
	then
		echo "Params should be integers" >&2
		return 1
	fi
	if [ $base -lt 0 ]
	then
		echo "Base should be positive" >&2
		return 3
	fi
	if [ $base -lt $val ]
	then
		echo "Base should be greater than value" >&2
		return 2
	fi
	if [ $val -lt 0 ]
	then
		sign='-'
	else
		sign='+'
	fi
	if [ $val -eq 0 ]
	then
		echo '~'
	else
		# Weird ?
		printf "%0.s$sign" {1..$(seq 1 $(echo "scale=0;1+$val/($base/$SCALE)*$val/sqrt($val^2)" | bc ))}
	fi
}
