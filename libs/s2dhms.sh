#!/usr/bin/env bash
function s2dhms {	# Convert seconds to day hour min sec, or xx:xx:xx if -I. Usage: $0 <int>
	if [ "$1" == '-I' ]
	then
		FORMAT='I'
		shift
	else
		FORMAT='S'
	fi
	w="$1"
	[ -z "$w" ] && read -r w
	if ! [[ $w =~ ^[0-9]+$ ]]
	then
		echo '    NaN    '
		return
	fi
	if [ "$FORMAT" == "I" ] && [ "$w" -ge "8640000" ]
	then
		echo '    OoR    '
		return
	fi
	dw="$(echo "$w/86400" | bc)"   # Day Warning
	w="$(echo "$w%86400" | bc)"
	hw="$(echo "$w/3600" | bc)"
	w="$(echo "$w%3600" | bc)"
	mw="$(echo "$w/60" | bc)"
	w="$(echo "$w%60" | bc)"
	case "$FORMAT" in
		S) 
			sdw="$([ "$dw" -ne 0 ] && echo "${dw}d")"    # String Day Warning
			shw="$([ "$hw" -ne 0 ] && echo "${hw}h")"
			smw="$([ "$mw" -ne 0 ] && echo "${mw}min")"
			sw="$([ "$w" -ne 0 ] && echo "${w}s")"
			z_tot='0s'
			;;
		I)
			sdw="$(printf "%02d:" "${dw}")"
			shw="$(printf "%02d:" "${hw}")"
			smw="$(printf "%02d:" "${mw}")"
			sw="$(printf "%02d" "${w}")"
			z_tot='00:00:00'
			;;
	esac
	tot="${sdw}${shw}${smw}${sw}"
	if [ -z "$tot" ]
	then
		echo "$z_tot"
	else
		echo "$tot"
	fi
}
