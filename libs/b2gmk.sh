function koca_b2gmk {	# Convert byte to giga, mega, kilo (tera, peta). Usage: $0 <integer>
	w="$1"
	if ! [[ "$w" =~ ^[0-9]+$ ]]
	then
		echo '?'
		return 1
	fi

	[ -z "$w" ] && read w
	#symbols=(. k M G T P ) # Eo, Zo and Yo are too big. 'o' is for alignment
	values=( 1 $((1024**1)) $((1024**2)) $((1024**3)) $((1024**4)) $((1024**5)) $((1024**6)) )
	echo "w=$w;
	scale=1
	p=1024^5;if(w>=p) {print w/p;print \"P\";halt};
	p=1024^4;if(w>=p) {print w/p;print \"T\";halt};
	p=1024^3;if(w>=p) {print w/p;print \"G\";halt};
	p=1024^2;if(w>=p) {print w/p;print \"M\";halt};
	p=1024^1;if(w>=p) {print w/p;print \"k\";halt};
	p=1;if(w>=p) {scale=0;print w/p;halt};
	w
	"|bc
	return
	for i in $(seq ${#symbols[*]} -1 1)
	do
		if [ $w -ge ${values[$i]} ]
		then
			pw=$(echo "scale=1;$w/${values[$i]}" | bc)
			[ "$pw" != "0" ] && echo "${pw}${symbols[$i]}" && return
		fi
		w=$(echo "scale=0;$w%${values[$i]}" | bc)
	done

	echo "${w}"
}
