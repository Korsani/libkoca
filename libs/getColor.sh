#!/usr/bin/env bash
# Return color code in a specified var
# getColor var[+] color [ [ var[+] ] color [ ... ] ]
# Ex : getColor r red g green
#   will put the color code red in $r, and green in $g
# Ex : getColor ok higreen bgred
#   $ok will contain green on red
# Ex : getColor a red ; a="$a*" ; getColor a+ reset ;
#   $a will contain then the code of red, then a star, then the code of reset. Thus, echo "$a plop" will display a red star, followed by the string "plop"
# getColor list to get available colors. Output is colored only if it is a terminal.
# Example : getColor _g higreen _re reset _w white _p hipurple _r hired
function getColor { # Return a specified color code in a specified var. Usage: $0 <var>[+] <colorname>. $0 list
	if [ ! -t 0 ] ; then
		return
	fi
	#   For almost every uname...
	local tput_af ; tput_af="setaf"
	local tput_ab ; tput_ab="setab"
	local bold ; bold=bold
	local reset ; reset=sgr0
	# but FreeBSD doesn't use terminfo
	if [ "$(uname)" == "FreeBSD" ] ; then
		tput_af=AF
		tput_ab=AB
		bold=md
		reset=me
	fi
	function _getColor {
		alias echo="echo -n"
		local _bold ; _bold=$(tput $bold)
		case $1 in
			black) tput "$tput_af" 0;;
			red) tput "$tput_af" 1;;
			green) tput "$tput_af" 2;;
			brown) tput "$tput_af" 3;;
			blue) tput "$tput_af" 4;;
			purple) tput "$tput_af" 5;;
			cyan) tput "$tput_af" 6;;
			gray) tput "$tput_af" 7;;

			bgblack) tput "$tput_ab" 0;;
			bgred) tput "$tput_ab" 1;;
			bggreen) tput "$tput_ab" 2;;
			bgyellow) tput "$tput_ab" 3;;
			bgblue) tput "$tput_ab" 4;;
			bgpurple) tput "$tput_ab" 5;;
			bgcyan) tput "$tput_ab" 6;;
			bgwhite) tput "$tput_ab" 7;;

			hiblack) echo "$_bold$(_getColor black)" ;;
			hired) echo "$_bold$(_getColor red)" ;;
			higreen) echo "$_bold$(_getColor green)" ;;
			yellow) echo "$_bold$(_getColor brown)" ;;
			hiblue) echo "$_bold$(_getColor blue)" ;;
			hipurple) echo "$_bold$(_getColor purple)" ;;
			hicyan) echo "$_bold$(_getColor cyan)" ;;
			white) echo "$_bold$(_getColor gray)" ;;

			bold) echo "$_bold" ;;
			reset) tput "$reset" ;;
		esac
		unalias echo
	}
	local misccolors ; misccolors='reset bold '
	local alllowcolors ; alllowcolors='green brown red black blue cyan purple gray'
	local allhicolors ; allhicolors='higreen yellow hired hiblack hiblue hicyan hipurple white'
	local allbgcolors ; allbgcolors='bggreen bgyellow bgred bgblack bgblue bgcyan bgpurple bgwhite'
	local allcolors ; allcolors=" $alllowcolors $allhicolors $allbgcolors $misccolors "

	if [ "$1" == "list" ] ; then
		local r ; r="$(_getColor reset)"
		local i
		for i in $allcolors ; do
			if [ -t 1 ] ; then
				echo "$r# $(_getColor "$i")$i$r"
			else
				echo "# $i"
			fi
		done
		echo "Usage: getColor var[+] color [ [ var[+] ] color [ ... ] ]"
		return 0
	fi
	[ "$#" -eq 1 ] && echo 'Bad number of arguments' >&2 && return 1
	while [ -n "$1" ] ; do
		if ! echo "$allcolors" | grep -q " $1 " ; then
			#echo "$1 is not a color, so it's a var"
			local var ; var="$1"
			augmented=0
			# If there is a '+' a the end of the var, it should be appended with color code
			if echo "$var" | grep -E -q '\+$' ; then
				augmented=1
				# strip the trailing '+'
				var=${var%%+}
			fi
			name="$2"
			shift
		else
			#echo "$1 is a color"
			name="$1"
			# and the variable should be in (previously set) 'var'
			augmented=1
		fi
		# '$var' is the name of the variable, for example : 'a'
		# $(echo $"$var")" return that name
		# \$$(echo $"$var")" is the "variabilized" name of that variable, for example : $a
		# eval echo \$$(echo $"$var")" return the value of that variable. If 'a' contain '1', this should return '1'
		local _val
		if [ $augmented -eq 1 ] ; then
			_val="$(eval echo \$$"$(echo $"${var%%+}")" 2>/dev/null)"
		else
			unset _val
		fi
		#echo "old value of 'var' is : $val"
		shift
		if echo " $allcolors " | grep -q " $name " ; then
			eval "${var}"=$"$_val"$"\$(_getColor "$name")"
		else
			if [ -z "$name" ] ; then
				echo "${FUNCNAME[0]}: Missing a color after variable '$var'"
			else
				echo "${FUNCNAME[0]}: $name is not a valid color. Try '${FUNCNAME[0]} list'"
			fi
			return
		fi
	done
}
