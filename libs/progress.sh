function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string> [ <int> ]
	local COLUMNS=$(tput cols)
	LANG=C  		        # avoid ./, mistake
	local progress="$1" ;[[ $progress =~ ^[0-9]+$ ]] || return 1; [ $progress -gt 100 ] && return 2
	local suf="$2" 
	local NSLICES=${3:-2};[[ $NSLICES =~ ^[0-9]+$ ]] || return 1 
	local SPARSE=$(expr 7 + ${#suf})    # 'xxx% '(5) '['(1) ']'(1)
	local slice_size=$(expr \( $COLUMNS - $SPARSE \) \/ $NSLICES)
	local RATIO=$(echo "scale=2;($COLUMNS-$SPARSE)/100"| bc)
	#printf "\r%-4s [" "$progress%"
	local fill=$(printf '%.0f' $(echo "scale=0;$progress*$RATIO"|bc))
	local empty=$(expr $COLUMNS - $SPARSE - $fill )
	# On FreeBSD, head complainx when -c 0
	#s=$(printf "\r%-4s [%s%s]%s" $progress% "$(head -c $fill < /dev/zero 2>/dev/null | tr '\0' '#')" "$(head -c $empty < /dev/zero 2>/dev/null| tr '\0' '_')" "$suf")
	local bar=$(printf "%s%s" "$(head -c $fill < /dev/zero 2>/dev/null | tr '\0' '#')" "$(head -c $empty < /dev/zero 2>/dev/null| tr '\0' '_')")
	# Display |
	local s=$(printf "\r%-4s [" "$progress%")
	for p in $(seq 0 $(( $NSLICES-2 )) )
	do
		s="$s${bar:$slice_size*$p:$slice_size-1}"
		s="$s|"
	done
	s="$s${bar:$(($slice_size * ($NSLICES-1))):$slice_size}]$suf"
	printf "%-$((COLUMNS+1))s" "$s"
}
