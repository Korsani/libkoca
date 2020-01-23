function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string> [ <int> ]
	local COLUMNS=$(tput cols)
	LANG=C  		        # avoid ./, mistake
	local progress="$1" ;[[ $progress =~ ^[0-9]+$ ]] || return 1; [ $progress -gt 100 ] && return 2
	local suf="$2" 
	local NSLICES=${3:-2};[[ $NSLICES =~ ^[0-9]+$ ]] || return 1 
	local SPARSE=$(expr 7 + ${#suf})    # 'xxx% '(5) '['(1) ']'(1)
	local slice_size=$(expr \( $COLUMNS - $SPARSE \) \/ $NSLICES)
	# Do all the math in bc, thus save some forks...
	declare -a barfullness
	local barfullness=($(echo "scale=0;f=$progress*($COLUMNS-$SPARSE)/100;e=($COLUMNS-$SPARSE-f);print f,\" \",e"|bc))
	# On FreeBSD, head complainx when -c 0
	local bar=$(printf "%s%s" "$(head -c ${barfullness[0]} < /dev/zero 2>/dev/null | tr '\0' '#')" "$(head -c ${barfullness[1]} < /dev/zero 2>/dev/null| tr '\0' '_')")
	# - How to put a char at a specific pos in a string, as quick as possible? Please avoid sed blabla stuf...
	# - Hold my beer
	declare -a magic
	# Transform a string in array
	local magic=($(echo $bar | sed -e 's/\(.\)/\1 /g'))
	# put | at specific pos in the array
	for marker_pos in $(seq 1 $(( NSLICES-1 )) )
	do
		magic[$[marker_pos*slice_size]]='|'
	done
	# Array back in string
	bar=$(echo ${magic[@]} | tr -d ' ')
	local s=$(printf "\r%-4s [%s]%s" "$progress%" "$bar" "$suf" )
	# Guarantee to fill with blanks
	printf "%-$((COLUMNS+1))s" "$s"
}
