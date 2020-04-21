#!/usr/bin/env bash
function koca_b2gmk {	# Convert byte to giga, mega, kilo (tera, peta). Usage: $0 <integer>
	w="$1"
	if ! [[ "$w" =~ ^[0-9]+$ ]]
	then
		echo '?'
		return 1
	fi

	[ -z "$w" ] && read -r w
	symbols=(. k M G T P ) # Eo, Zo and Yo are too big. 'o' is for alignment
	for i in $(seq ${#symbols[*]})
	do
		values[$i]="$(echo 1024^$i|bc)"
	done
	for i in $(seq ${#symbols[*]} -1 1)
	do
		if [ "$w" -ge "${values[$i]}" ]
		then
			pw="$(echo "scale=1;$w/${values[$i]}" | bc)"
			[ "$pw" != "0" ] && echo "${pw}${symbols[$i]}" && return
		fi
		w="$(echo "scale=0;$w%${values[$i]}" | bc)"
	done

	echo "${w}"
}
