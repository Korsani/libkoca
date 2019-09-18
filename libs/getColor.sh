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
function getColor { # Return a specified color code in a specified var
	if [ ! -t 0 ]
	then
		return
	fi
	#   For almost every uname...
    local tput_af="setaf"
    local tput_ab="setab"
    local bold=bold
    local reset=sgr0
	# but FreeBSD doesn't use terminfo
	if [ "$(uname)" = "FreeBSD" ]
	then
		tput_af=AF
		tput_ab=AB
		bold=md
		reset=me
	fi
	function _getColor {
	alias echo="echo -n"
	local _bold=$(tput $bold)
		case $1 in 
			black) echo $(tput $tput_af 0);;
			red) echo $(tput $tput_af 1) ;;
			green) echo $(tput $tput_af 2) ;;
			brown) echo $(tput $tput_af 3) ;;
			blue) echo $(tput $tput_af 4) ;;
			purple) echo $(tput $tput_af 5) ;;
			cyan) echo $(tput $tput_af 6) ;;
			gray) echo $(tput $tput_af 7) ;;

			bgblack) echo $(tput $tput_ab 0);;
			bgred) echo $(tput $tput_ab 1) ;;
			bggreen) echo $(tput $tput_ab 2) ;;
			bgyellow) echo $(tput $tput_ab 3) ;;
			bgblue) echo $(tput $tput_ab 4) ;;
			bgpurple) echo $(tput $tput_ab 5) ;;
			bgcyan) echo $(tput $tput_ab 6) ;;
			bgwhite) echo $(tput $tput_ab 7) ;;

			hiblack) echo $_bold$(_getColor black) ;;
			hired) echo $_bold$(_getColor red) ;;
			higreen) echo $_bold$(_getColor green) ;;
			yellow) echo $_bold$(_getColor brown) ;;
			hiblue) echo $_bold$(_getColor blue) ;;
			hipurple) echo $_bold$(_getColor purple) ;;
			hicyan) echo $_bold$(_getColor cyan) ;;
			white) echo $_bold$(_getColor gray) ;;

			bold) echo $_bold ;;
			reset) echo $(tput $reset) ;;
		esac
		unalias echo
	}
    local misccolors='reset bold '
	local alllowcolors='green brown red black blue cyan purple gray'
	local allhicolors='higreen yellow hired hiblack hiblue hicyan hipurple white'
	local allbgcolors='bggreen bgyellow bgred bgblack bgblue bgcyan bgpurple bgwhite'
	local allcolors=" $alllowcolors $allhicolors $allbgcolors $misccolors "

	if [ "$1" == "list" ]
	then
		local r=$(_getColor reset)
		local i
		for i in $allcolors
		do
			if [ -t 1 ]
			then
				echo "$r# $(_getColor $i)$i$r"
			else
				echo "# $i$r"
			fi
		done
		echo "Usage : getColor var[+] color [ [ var[+] ] color [ ... ] ]"
		return 0
	fi
	[ $(expr ${#*}) -eq 1 ] && echo 'Bad number of arguments' >&2 && return 1
	while [ "$1" != "" ]
	do
		if ! $(echo "$allcolors" | grep -q " $1 ")
		then
			#echo "$1 is not a color, so it's a var"
			local var=$1
			augmented=0
			# If there is a '+' a the end of the var, it should be appended with color code
			if $(echo $var | grep -E -q '\+$')
			then
				augmented=1
				# strip the trailing '+'
				var=${var%%+}
			fi
			name=$2
			shift
		else
			#echo "$1 is a color"
			name=$1
			# and the variable should be in (previously set) 'var'
			augmented=1
		fi
        # '$var' is the name of the variable, for example : 'a'
        # $(echo $"$var")" return that name
        # \$$(echo $"$var")" is the "variabilized" name of that variable, for example : $a
        # eval echo \$$(echo $"$var")" return the value of that variable. If 'a' contain '1', this should return '1'
		local _val
		if [ $augmented -eq 1 ]
		then
			_val="$(eval echo \$$"$(echo $"${var%%+}")" 2>/dev/null)"
		else
			unset _val
		fi
        #echo "old value of 'var' is : $val"
		shift
        if echo " $allcolors "| grep -q " $name "
        then
			eval ${var}=$"$_val"$"\$(_getColor "$name")"
        else
            if [ "$name" = "" ]
            then
                echo "$FUNCNAME : Missing a color after variable '$var'"
            else
                echo "$FUNCNAME : $name is not a valid color. Try '$FUNCNAME list'"
            fi
            return
        fi
	done
}
