#!/usr/bin/env bash
function koca_banner() {	# Display string in a banner way: chars one by one, at givent speed. Usage: $0 [@]<string> <float>
	function _disp() {
		local str;str"$1"
		local pause;pause="$2"
  		for n in $(seq 1 ${#str})
   	 	do
       		echo -en "\r${str:0:$n}"
			[ "${str:$n:1}" != " " ] && sleep "$pause"
    	done
		echo
	}
	# How long a loop take?
	local t_loop;t_loop="$( (time _disp n) 2>&1 | grep real | sed -e 's/.*m\([0-9]*\).\([0-9]*\)s/\1.\2/')"
    local str;str="$1"		# Can be a string, file and suffixed by @speed
    local uspeed;uspeed="$2"	# Speed given by user
	local speed_cps
	local str_unspaced
	[ -z "$str" ] && return 1
    [ -z "$uspeed" ] && uspeed='30cps'
	if [[ $str =~ ^@ ]]		# str is a file
	then
		str_unspaced="$( tr -d '[:blank:]' < "${str#@}" )"			# As spaces will not be 'waited', I have to build a non-spaced string
	else
		str_unspaced="$( echo "$str" | tr -d '[:blank:]' )"			# As spaces will not be 'waited', I have to build a non-spaced string
	fi
	[[ $uspeed =~ ^[0-9]*[\.,]?[0-9]+$ ]] && uspeed="$(echo $uspeed | tr ',' '.')s"			# In s if nothing is given
	[[ $uspeed =~ ^[0-9]*[\.,]?[0-9]+s$ ]] && speed_cps=$(echo "scale=2;${#str_unspaced}/${uspeed%%s}" | bc)	# Speed is given in seconds. Convert in cps
	[[ $uspeed =~ ^[0-9]+cps$ ]] && speed_cps=${uspeed%%cps}		# Speed is given in cps
	if [ -z "$speed_cps" ]
	then
		echo "[__libname__] Speed was not given in a suitable form" >&2
		return 1
	fi
	# If calculated pause is less than the duration of the loop, set pause to 0, and... time taken to display will be longer than expected...
	local pause;pause="$( echo "scale=10;pause=1/$speed_cps;if (pause<$t_loop) 0 else pause-$t_loop" | bc )"
	#local w2=$(echo "scale=10;1/$speed_cps" | bc)
	#echo "size:${#str_unspaced} speed:${speed_cps}cps loop:$t_loop wait:${w2}s pause:${pause}s r=" $(echo "scale=2;$w2/$t_loop"|bc)
	#return
	#time (
	if [[ $str =~ ^@ ]]
	then
		while read -r str2
		do
			_disp "$str2" "$pause"
		done <"${str#@}"
	else
		_disp "$str" "$pause"
	fi
	#)
	return 0
}
