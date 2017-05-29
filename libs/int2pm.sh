# Return the number converted in +/- scale
function int2pm { # return +, ++, +++ (or -). <val> <base> [ <scale> [ <sign+><sign-> [ "gauge" ] ] ] 
	local val="$1"
	local base="$2"
	local SCALE=3
	local SIGNS='+-'
	[ -n "$3" ] && SCALE="$3"
	[ -n "$4" ] && SIGNS="$4"
	[ "$5" = "gauge" ] && MIXED="y"
	
	if ! ( [[ $base =~ ^[0-9]+$ ]] && [[ $val =~ ^-?[0-9]+$ ]] && [[ $SCALE =~ ^[0-9]+$ ]])
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
		sign=${SIGNS:1:1}
	else
		sign=${SIGNS:0:1}
	fi
	if [ $val -eq $base ]
	then
		printf "%0.s$sign" {$(seq 1 $SCALE)}
		return 0
	fi
	if [ $val -eq 0 ]
	then
		r='~'
	else
		# Weird ?
		r=$(printf "%0.s$sign" {$(seq 1 $(echo "scale=0;1+$val/($base/$SCALE)*$val/sqrt($val^2)" | bc ))})
		if [ -n "$MIXED" ]
		then
			r+=$(printf "%0.s${SIGNS:1:1}" {$(seq 1 $(echo "scale=0;($base-$val)/($base/$SCALE)*$val/sqrt($val^2)" | bc ))})
		fi
	fi
	echo $r
}
