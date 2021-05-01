#!/usr/bin/env bash
# Return the number converted in +/- scale
function koca_int2pm { # return +, ++, +++ (or -). Usage: $0 <value> [ <max> [ <length> [ 'gauge' [ <sign+><sign-> ] ] ] ]
	local val="$1"
	local MAX=3
	local LENGTH=3
	local SIGNS='+-'
	local GAUGE=''
	[ -n "$5" ] && SIGNS="$5"
	[ -n "$3" ] && LENGTH="$3"
	[ -n "$2" ] && MAX="$2"
	[ "$4" == "gauge" ] && GAUGE="y"
	
	if ! ( [[ $MAX =~ ^[0-9]+$ ]] && [[ $val =~ ^-?[0-9]+$ ]] && [[ $LENGTH =~ ^[0-9]+$ ]]) ; then
		echo "[${FUNCNAME[0]}] Params should be integers" >&2
		return 1
	fi
	if [ "$MAX" -lt 0 ] ; then
		echo "[${FUNCNAME[0]}] Max ($MAX) should be positive" >&2
		return 3
	fi
	if [ -n "$GAUGE" ] && [ "$val" -lt 0 ] ; then
		echo "[${FUNCNAME[0]}] Value ($val) must be positive when using gauge" >&2
		return 3
	fi
	if [ "$MAX" -lt "$val" ] ; then
		echo "[${FUNCNAME[0]}] Max ($MAX) should be greater than value ($val)" >&2
		return 2
	fi
	if [ "$val" -lt 0 ] ; then
		sign=${SIGNS:1:1}
	else
		sign=${SIGNS:0:1}
	fi
	if [ "$val" -eq "$MAX" ] ; then
		printf "%0.s$sign" {$(seq 1 "$LENGTH")}
		echo
		return 0
	fi
	if [ "$val" -eq 0 ] ; then
		r='~'
	else
		# Weird ?
		n="$(echo "scale=2;r=$val/($MAX/$LENGTH)*$val/sqrt($val^2); if (r>$LENGTH) r=$LENGTH; r" | bc )"
		# Fucking bc that is not able to say me wether a number is integer or not ...
		if [[ $n =~ .00$ ]] ; then
			n="$(echo "$n" | cut -d '.' -f 1)"
		else
			n="$(($(echo "$n" | cut -d '.' -f 1)+1))"
		fi
		r="$(printf "%0.s$sign" {$(seq 1 $n)})"
		if [ -n "$GAUGE" ] ; then
			if [ "$n" -ne "$LENGTH" ] ; then
				r+="$(printf "%0.s${SIGNS:1:1}" {$(seq $((n+1)) "$LENGTH")})"
			fi
		fi
	fi
	echo "$r"
}
