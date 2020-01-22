#http://is.gd/qQc5ab
function koca_spin {	# Display a spinning cursor or scrolling text. Usage: $0 [ <int|string> [ <-1|0|1> [ <int> ] ] ]. $0 list
	local spin=${1:-0}
	local dir=${2:-1}
	local length=${3:-1}
	declare -A koca_spin ; local koca_spin
	koca_spin[0]='/-\|/-\|'
	koca_spin[1]='|>=<|<=>' 
	koca_spin[2]='O○·○'
	koca_spin[3]='[{(|)}]'
	koca_spin[4]='.oOo'
	case $spin in
		[0-9]) ;;
		 list) for n in ${!koca_spin[*]} ; do echo "$n:${koca_spin[$n]}" ; done ; return ;;
		    *) koca_spin[0]="$1" ; spin=0 ;;
	esac
	if [ $length -gt ${#koca_spin[$spin]} ]
	then
		echo "[__libname__] Length ($length) must not be greater than the string length (${#koca_spin[$spin]})" >&2
		return 1
	fi
	if ! [[ $dir =~ [01$] ]] 
	then
		echo "[__libname__] Direction must be -1, 0 or 1, not $dir" >&2
		return 1
	fi
	[ $spin -ge ${#koca_spin[*]} ] && spin=0
	declare -a index ; local index
	# Make equation easier to write
	local a=$dir ; local n=${#koca_spin[$spin]}-$length
	[ $dir -eq 0 ] && a=1	# Deal with that case later
	# Build index of position from where to write
	# Nii... Make first term to 0 when a=1, n when a=-1
	index=( $(seq $((a*n*(a-1)/2)) $a $((n-a*n*(a-1)/2)) ) )
	if [ $dir -eq 0 ] 		# Bouncing: generate the same sequence, backward, starting from n-1, till 1 (as sequence start with 0)
	then
		index=( ${index[@]} $(seq $((n-1)) -1 1) )
	fi
	# Display $length car, starting from somewhere 
	printf "\r${koca_spin[$spin]:${index[$koca_spin_pos]}:$length}"
	# Moving forward in index
	(( koca_spin_pos=(koca_spin_pos+1)%${#index[@]} ))
	# Mmm...
	return 0
}
