function dhms2s {	# Convert a 'day hour min sec' string to seconds. Usage: $0 <string>
	# can be specified in any order :
	# 1d1s is the same as 1s1d
	w=$1
	[ -z "$w" ] && read w
	local op=$(echo "$w" | sed -e 's/\([0-9]*\)d/\1*86400 + /' -e 's/\([0-9]*\)h/\1*3600 + /' -e 's/\([0-9]*\)min/\1*60 + /' -e 's/\([0-9]*\)s/\1 + /' -e 's/+ $//' -e 's/$/+0/' | sed -e 's/  /0/')
	if [[ $op =~ ^[0-9.\+\ \*]+$ ]]
	then
		echo $op | bc
	else
		echo '-1'
	fi
}
