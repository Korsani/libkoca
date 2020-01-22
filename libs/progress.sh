function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string>
	local COLUMNS=$(tput cols)
	LANG=C  		        # avoid ./, mistake
	local progress="$1" ;
	[[ $progress =~ ^[0-9]+$ ]] || return 1	# should also catch negative numbres
	[ $progress -gt 100 ] && return 2
	local suf="$2"
	local SPARSE=$(expr 7 + ${#suf})    # 'xxx% '(5) '['(1) ']'(1)
	local RATIO=$(echo "scale=2;($COLUMNS-$SPARSE)/100"| bc)
	#printf "\r%-4s [" "$progress%"
	local fill=$(printf '%.0f' $(echo "scale=0;$progress*$RATIO"|bc))
	local empty=$(expr $COLUMNS - $SPARSE - $fill )
	local half=$(expr \( $COLUMNS - $SPARSE \) \/ 2)
	# On FreeBSD, head complainx when -c 0
	s=$(printf "\r%-4s [%s%s]%s" $progress% "$(head -c $fill < /dev/zero 2>/dev/null | tr '\0' '#')" "$(head -c $empty < /dev/zero 2>/dev/null| tr '\0' '_')" "$suf")
	# Display a | in the middle
	printf "%s|%s" "${s:0:7+$half-1}" "${s:7+$half}"
}
