function koca_banner() {	# Display string in a banner way: chars one by one, at givent speed
    local str="$1"
    local uspeed="$2"	# Speed given by user
	[ -z "$str" ] && return 1
    [ -z "$uspeed" ] && uspeed='30cps'
	local str_unspaced=$(echo "$str" | tr -d ' ')			# As spaces will not be 'waited', I have to build a non-spaced string
	[[ $uspeed =~ ^[0-9]$ ]] && uspeed+='s'			# In s if nothing is given
	[[ $uspeed =~ [0-9]+s ]] && speed_cps=$(echo "scale=2;${#str_unspaced}/${uspeed%%s}" | bc)	# Speed is given in seconds. Convert in cps
	[[ $uspeed =~ [0-9]+cps ]] && speed_cps=${uspeed%%cps}		# Speed is given in cps
    local w=$(echo "scale=10;1/$speed_cps" | bc)
    for n in $(seq 1 ${#str})
    do
        echo -en "\r${str:0:$n}"
		[ "${str:$n:1}" != " " ] && sleep $w
        #[ $n -lt ${#str} ] && sleep $w	# Sleep if it's no the last char
    done
	echo
}
