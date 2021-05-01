#!/usr/bin/env bash
function koca_b2gmk {	# Convert byte to giga, mega, kilo (tera, peta). Usage: $0 <integer>
	w="$1"
	if ! [[ "$w" =~ ^[0-9]+$ ]] ; then
		echo '?'
		return 1
	fi

	[ -z "$w" ] && read -r w
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
}
