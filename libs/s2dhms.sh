function s2dhms {	# Convert seconds to day hour min sec, or xx:xx:xx if -I. Usage: $0 <int>
	if [ "$1" == '-I' ]
	then
		FORMAT='I'
		shift
	else
		FORMAT='S'
	fi
	w="$1"
	[ -z "$w" ] && read w
	if ! [[ $w =~ ^[0-9]+$ ]]
	then
		echo '    NaN    '
		return
	fi
	if [ "$FORMAT" -eq 1 -a $w -ge 8640000 ]
	then
		echo '    OoR    '
		return
	fi
	echo "f=$FORMAT;dw=$w/86400;w=$w%86400;hw=w/3600;w%=3600;mw=w/60;w%=60;
	if(f==0) {
		if(dw!=0) print dw,\"d\";
		if(hw!=0) print hw,\"h\";
		if(mw!=0) print mw,\"min\";
		if(w!=0) print w,\"s\";
	}
	if(f==1) {
		if(dw<10) print 0;print dw;\":\";
		if(hw<10) print 0;print hw;\":\";
		if(mw<10) print 0;print mw;\":\";
		if(w<10) print 0;print w;
	}
	"|bc
}
