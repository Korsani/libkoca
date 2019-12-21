function koca_banner() {	# Display string in a banner way: chars one by one, at givent speed
    local str="$1"
    local speed="$2"
	[ -z "$str" ] && return 1
    [ -z "$speed" ] && speed=500
    w=$(echo "scale=10;1/$speed" | bc)
    for n in $(seq 0 ${#str})
    do
        echo -en "\r${str:0:$n}"
        sleep $w
    done
	echo
}
