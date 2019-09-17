#http://is.gd/qQc5ab
function koca_spin {	# Display a spinning cursor
	declare -A koca_spin
	koca_spin[0]='/-\|/-\|'
	koca_spin[1]='|)}>-<{(|({<->})' 
	koca_spin[2]='O○·○'
	spin="$1"
	[ -z "$spin" ] && spin=0
	[ $spin -gt ${#koca_spin[*]} ] && spin=0
	#printf "\b"${koca_spin[$koca_spin_pos]} 
	printf "\b"${koca_spin[$spin]:$koca_spin_pos:1} 
    (( koca_spin_pos=(koca_spin_pos +1)%${#koca_spin[$spin]} ))
}
