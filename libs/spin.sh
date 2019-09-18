#http://is.gd/qQc5ab
function koca_spin {	# Display a spinning cursor
	spin=${1:-0}
	declare -A koca_spin
	koca_spin[0]='/-\|/-\|'
	koca_spin[1]='|>=<|<=>' 
	koca_spin[2]='O○·○'
	case $spin in
		[0-9]) ;;
		   list) for n in ${!koca_spin[*]} ; do echo "$n:${koca_spin[$n]}" ; done ; return ;;
			*) koca_spin[0]=$1 ; spin=0 ;;
	esac
	[ $spin -ge ${#koca_spin[*]} ] && spin=0
	printf "\b"${koca_spin[$spin]:$koca_spin_pos:1} 
    (( koca_spin_pos=(koca_spin_pos +1)%${#koca_spin[$spin]} ))
}
