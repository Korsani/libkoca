# Return the number converted in +/- scale
function int2pm { # return +, ++, +++ (or -). <val> <base> [ <scale> [ gauge [ <sign+><sign-> ] ] ] 
	local val="$1"
	local base="$2"
	local SCALE=3
	local SIGNS='+-'
	[ -n "$5" ] && SIGNS="$5"
	[ -n "$3" ] && SCALE="$3"
	[ "$4" = "gauge" ] && MIXED="y"
	
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
	if [ -n "$MIXED" -a $val -lt 0 ]
	then
		echo "Val must be positive when using gauge" >&2
		return 3
	fi
	if [ $base -lt $val ]
	then
		echo "Base should be greater than value" >&2
		return 2
	fi
	if [ $SCALE -gt $base ]
	then
		echo "Scale should be less than base" >&2
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
		n=$(echo "scale=0;r=1+$val/($base/$SCALE)*$val/sqrt($val^2);if (r>$SCALE) print $SCALE else print r" | bc )
		r=$(printf "%0.s$sign" {$(seq 1 $(echo "scale=0;r=1+$val/($base/$SCALE)*$val/sqrt($val^2);if (r>$SCALE) print $SCALE else print r" | bc ))})
		if [ -n "$MIXED" ]
		then
			if [ $n -ne $SCALE ]
			then
				r+=$(printf "%0.s${SIGNS:1:1}" {$(seq $((n+1)) $SCALE)})
			fi
		fi
	fi
	echo $r
}
