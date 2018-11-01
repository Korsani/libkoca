# Lib of useful function, for shell addicts
# Inclusions of function depend on wether it as succeeded to shunit or not
# Brought to you under GPL Licence, by Gab

_outdated() {
    eval alias $1="\"echo '[libkoca.sh] Please use koca_$1, instead of $1'; koca_$1\""
}
function koca_b2gmk {	# byte to giga, mega, kilo (tera, peta)
	w="$1"
	if ! [[ "$w" =~ ^[0-9]+$ ]]
	then
		echo '?'
		return 1
	fi

	[ -z "$w" ] && read w
	symbols=(. k M G T P ) # Eo, Zo and Yo are too big. 'o' is for alignment
	for i in $(seq ${#symbols[*]})
	do
		values[$i]=$(echo 1024^$i|bc)
	done
	for i in $(seq ${#symbols[*]} -1 1)
	do
		if [ $w -ge ${values[$i]} ]
		then
			pw=$(echo "scale=1;$w/${values[$i]}" | bc)
			[ "$pw" != "0" ] && echo "${pw}${symbols[$i]}" && return
		fi
		w=$(echo "scale=0;$w%${values[$i]}" | bc)
	done

	echo "${w}"
}
# Check wether specified file can be found, warn or exit according it's a MAY or a MUST
# Initialize the variable with the path of the correspondant file, if the file is found
# Initialize the variable with 'echo <commande>' if the file is not found
# checkNeededFiles may [ file [ file [ ... ] ]
# checkNeededFiles must [ file [ file [ ... ] ]
# Example :
# > checkNeededFiles may bash
# > echo $bash
# > /bin/bash
# Example : 
# > checkNeededFiles may conntrack # supposing conntrack is is not installed
# > $conntrack -D -s 1.1.1.1
# > conntrack -D -s 1.1.1.1
function checkNeededFiles {
	local _ec=0
	while [ -n "$1" ]
	do
		case $1 in
			-q)
				local quiet='yes'
				;;
			may|must)
				type=$1;;
			*)
				if ! type -p "$1" >/dev/null 2>&1
				then
					[ "$type" = "may" ] && [ -z "$quiet" ] && echo "[libkoca.sh] '$1' not found. Bad things may happen" >&2 && ((_ec++))
					[ "$type" = "must" ] && [ -z "$quiet" ] && echo "[libkoca.sh] '$1' not found. Bad things WILL happen" >&2 && ((_ec++))
					if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
					then
						eval export $1=\"echo '$1'\"
					else
						[ -z "$quiet" ] && echo "[libkoca.sh] Var '$1' won't be exported"
					fi
                else
					if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
					then
                    	eval export $1=$(which "$1")
					else
						[ -z "$quiet" ] && echo "[libkoca.sh] Var '$1' won't be exported"
					fi
				fi
				;;
		esac
		shift
	done
	return $_ec
}
# Efface certains fichiers a la sortie du programme
# Utilisation:
# cleanOnExit <liste de fichiers>
# Bug : si 'cleanOnExit' est utilisé dans une fonction chargé dans l'environnement du shell courant, alors rien ne sera fait à la sortie de la fonctions, ni à la sortie du shell
# En d'autres termes, dans ce cas :
# $ cat plop
# f()
#	{
#	t=`mktemp`
#	cleanOnExit $t
# }
# $ . libkoca.sh
# $ . plop
# $ f
# Le fichier temporaire ne sera jamais effacé
function koca_cleanOnExit { # Remove specified file on script exit
	local file
	for file in "$@"
	do
		local t=$(trap -p 0)
		[ -n "$t" ] && _oldTrap0=$(echo "$t ;" | sed -e "s/trap -- '\(.*\)' EXIT/\1/")
		trap "$_oldTrap0 rm -f \"$file\"" 0
	done
}
function dhms2s {	# day hour min sec to seconds
	# can be specified in any order :
	# 1d1s is the same as 1s1d
	w=$1
	[ -z "$w" ] && read w
	local op=$(echo "$w" | sed -e 's/\([0-9]*\)d/\1*86400 + /' -e 's/\([0-9]*\)h/\1*3600 + /' -e 's/\([0-9]*\)min/\1*60 + /' -e 's/\([0-9]*\)s/\1 + /' -e 's/+ $//' -e 's/$/+0/' | sed -e 's/  /0/')
	if [[ $op =~ ^[0-9.\+\ \*]+$ ]]
	then
		echo $op | bc
	else
		echo '-1'
	fi
}
function dieIfNotRoot { # Exit calling script if not running under root
	local src=__libkoca__ ; [ -e $src ] && eval "$(bash $src gotRoot)"
	! gotRoot && echo "[libkoca.sh] Actually, I should be run as root" && exit 1
	#! underSudo && echo "[libkoca.sh] Actually, I should be run under sudo" && exit 1
	return 0
}
function dieIfRoot { # Exit calling script if run under root
	local src=__libkoca__ ; [ -e $src ] && eval "$(bash $src gotRoot)"
	gotRoot && echo "[libkoca.sh] I should not be run as root" && exit 1
	#underSudo && echo "[libkoca.sh] I should not be run under sudo" && exit 1
	return 0
}
function underSudo { # Return wether the calling script is run under sudo
	[ -n "$SUDO_USER" ]
}
function gotRoot { # Return wether the calling script is run under root
	[ $(id -u) -eq 0 ]
}
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
				echo "$r# $(_getColor $i)$i"
			else
				echo "# $i"
			fi
		done
		echo -ne $r
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
_getConfGetSedOption() {
	local opt
	case $(uname -s) in
        Darwin|FreeBSD)
        opt=E
        ;;
        OpenBSD)
        opt=''
        ;;
        Linux|*)
        opt=r
        ;;
    esac
	echo $opt
}
_getConfIsReadable() {
	# Sauf qu'un fichier est toujours lisible par root, même s'il 
	# a le mode 0000 ...
	local flag=1
	for file in $KOCA_CONF
	do
		# At least one is readable
		[ -r "$file" ] && flag=0
	done
	[ $flag -eq 1 ] && echo "[libkoca] No readable conf file provided. Please put one in an env var named 'KOCA_CONF'" >&2 && return 1
	[ $flag -eq 0 ] && return 0
	return 2
}
# Deprecated
getConf() {
	echo "[libkoca.sh)] Please use getConfValue" >&2
	echo "$(date -u +%Y%m%d%H%M%SZ) : $(cd $(dirname \"$0\") ; pwd)/$(basename \"$0\") : getConf" >> /var/libkoca/stats
	getConfValue "$*"
}
# Return values from a configuration file passed in $KOCA_CONF variable
# format of conf file : section.key=value
# Usage : getConfValue <section> <key>
function getConfValue {
## link: ## _getConfGetSedOption ##
## link: ## _getConfIsReadable ##
	# hey hey, dynamic linking :)
	# If included in a script, nothing is done
	# If get by eval, then get those 2 functions
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" _getConfGetSedOption _getConfIsReadable)"
	local opt=$(_getConfGetSedOption)
	_getConfIsReadable || return $?
	local val="$(grep -Eh "^$1\.$2[[:space:]]*=" "$KOCA_CONF" 2>/dev/null | sed -${opt}e 's/[^=*]+=\s*//'| tail -1)"
	[ -n "$val" ] && echo "$val" && return 0
	[ -n "$3" ] && echo "$3" && return 0
	return 2
}
# Return of the keys of a specified section
# Usage : getConfAllKeys <section>
function getConfAllKeys {
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" _getConfGetSedOption _getConfIsReadable)"
	local opt=$(_getConfGetSedOption)
	_getConfIsReadable || return $?
	local val=$(grep -Eh "^$1\." $KOCA_CONF | sed -e "s/^$1\.\(.*\)\s*=.*/\1/")
	[ -n "$val" ] && echo $val && return 0
	return 2
}
# Return all the sections of an eventulally given keys
# Usage : getConfAllSections [ <key> [ <key> [ ... ] ]
function getConfAllSections {
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" _getConfGetSedOption _getConfIsReadable)"
	local opt=$(_getConfGetSedOption)
	_getConfIsReadable || return $?
	local v
	if [ -z "$1" ]
    then
		v=$(grep -Eh "^[^[:space:]#].*\..*[\.\s=]" $KOCA_CONF | sed -e "s/^\(.*\)\..*\s*=.*/\1/" | sort -u | xargs)
    else
		while [ "$1" != "" ]
		do
			v="$v $(grep -Eh "^[^[:space:]#].*\.$1[\.\s=]" $KOCA_CONF | sed -e "s/^\(.*\)\..*\s*=.*/\1/" | sort -u | xargs)"
			shift
		done
    fi
	echo $v
}
# Return the number converted in +/- scale
function koca_int2pm { # return +, ++, +++ (or -). <value> [ <max> [ <length> [ 'gauge' [ <sign+><sign-> ] ] ] ]
	local val="$1"
	local MAX=3
	local LENGTH=3
	local SIGNS='+-'
	local GAUGE=''
	[ -n "$5" ] && SIGNS="$5"
	[ -n "$3" ] && LENGTH="$3"
	[ -n "$2" ] && MAX="$2"
	[ "$4" == "gauge" ] && GAUGE="y"
	
	if ! ( [[ $MAX =~ ^[0-9]+$ ]] && [[ $val =~ ^-?[0-9]+$ ]] && [[ $LENGTH =~ ^[0-9]+$ ]])
	then
		echo "[${FUNCNAME[0]}] Params should be integers" >&2
		return 1
	fi
	if [ $MAX -lt 0 ]
	then
		echo "[${FUNCNAME[0]}] Max ($MAX) should be positive" >&2
		return 3
	fi
	if [ -n "$GAUGE" -a $val -lt 0 ]
	then
		echo "[${FUNCNAME[0]}] Value ($val) must be positive when using gauge" >&2
		return 3
	fi
	if [ $MAX -lt $val ]
	then
		echo "[${FUNCNAME[0]}] Max ($MAX) should be greater than value ($val)" >&2
		return 2
	fi
#	if [ $LENGTH -gt $MAX ]
#	then
#		echo "[${FUNCNAME[0]}] Length ($LENGTH) should be less than max ($MAX)" >&2
#		return 2
#	fi
	if [ $val -lt 0 ]
	then
		sign=${SIGNS:1:1}
	else
		sign=${SIGNS:0:1}
	fi
	if [ $val -eq $MAX ]
	then
		printf "%0.s$sign" {$(seq 1 $LENGTH)}
		echo
		return 0
	fi
	if [ $val -eq 0 ]
	then
		r='~'
	else
		# Weird ?
		n=$(echo "scale=2;r=$val/($MAX/$LENGTH)*$val/sqrt($val^2); if (r>$LENGTH) r=$LENGTH; r" | bc )
		# Fucking bc that is not able to say me wether a number is integer or not ...
		if [[ $n =~ .00$ ]]
		then
			n=$(echo $n | cut -d '.' -f 1)
		else
			n=$(($(echo $n | cut -d '.' -f 1)+1))
		fi
		r=$(printf "%0.s$sign" {$(seq 1 $n)})
		if [ -n "$GAUGE" ]
		then
			if [ $n -ne $LENGTH ]
			then
				r+=$(printf "%0.s${SIGNS:1:1}" {$(seq $((n+1)) $LENGTH)})
			fi
		fi
	fi
	echo $r
}
function koca_isBackgrounded() { # Return true if process is backgrounded. Thanks to http://is.gd/4h3fk0
	case $(ps -o stat= -p $$) in
		*+*) return 1;;
		*) return 0;;
esac
}
function isIp { # return true if parameter is an IPv4/IPv6 address
	#echo "$1" | grep -q -E '^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$'
	local isv4=0
	local isv6=0
	echo "$1" | grep -q -E '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' ; isv4=$?
	if [ $isv4 -ne 0 ]
	then
		echo "$1" | grep -q -E '^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(([0-9A-Fa-f]{1,4}:){0,5}:((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(::([0-9A-Fa-f]{1,4}:){0,5}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$' ; isv6=$?
	fi
	[ $isv4 -eq 0 -o $isv6 -eq 0 ]
}
function koca_isNumeric { # return true if parameter is numeric
	[[ $1 =~ ^[+-]*[0-9.]+$ ]]
}
function koca_join { # join lines from STDIN with $1
	cat | sed -e ":a;N;\$!ba;s/\n/$1/g"
}
# Return true is load is less or equal to value
function koca_load() { # Return true if load is less or equals to specified float value
	thr=$1
	if [[ $thr =~ ^-?[0-9]+\.?[0-9]*$ ]]
	then
		return  $(bc <<< "$(cat /proc/loadavg | awk '{printf "%.0f",$1}') > $1")
	else
		echo "[libkoca.sh] '$1' is not a float or int" >&2
		return 2
	fi
}
# Fournit un mechanisme de lock: empeche plusieurs instances 
# de tourner en meme temps.
# Efface le lock s'il est vide, ou s'il ne correspond vraisemblablement pas au processus qui essait de le créer
# Utilisation:
# lockMe [ -q ] <fichier de lock> [ timeout ]
# -q : sort silencieusement si le timeout expire
# PS: le fichier ne devrait pas etre un `mktemp`, sinon ca risque pas de marcher cm prevu :)
function koca_lockMe { # Lock the calling script on the specified file
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" koca_cleanOnExit)"
	local quiet=0
	[ "$1" = "-q" ] && quiet=1 && shift
	if [ -z "$1" ]
	then
		local lock=/tmp/$(basename "$0").lock
	else
		local lock="$1"
	fi
	local to=60
	[ -n "$2" ] && to="$2"
	local n=0
	if [ -s "$lock" ]
	then
		# replace the shell by its absolute path (bash -> /bin/bash)
		c=$(ps -o command=COMMAND $(cat "$lock") | grep -v COMMAND | awk '{print $2}' | xargs echo $SHELL )
		# Should detect that /bin/bash plop.sh is the same as /bin/bash ./plop.sh
		if [[ ! "$c" =~ $SHELL" "\.?\/?$0.* ]]
		then
			[ "$quiet" -eq 0 ] && echo "[libkoca.sh] Stall lock ($c vs $SHELL $0). Removing."
			rm -f "$lock"
		fi
	else
		if [ -e "$lock" ]
		then
			echo "[libkoca.sh] Empty lock $lock. Removing"
			rm -f "$lock"
		fi
	fi
	while [ -e $lock -a $n -le $to ]
	do
		[ "$quiet" -eq 0 ] && echo "[libkoca.sh] An instance is running (pid : $(/bin/cat "$lock"))."
		[ "$(basename -- "$0")" == "bash" ] && return
		[ $to -eq 0 ] && exit 1
		sleep 1
		(( n++ ))
		# boucler plutot que sortir ?
	done
	if [ $n -gt $to -a -e $lock ]
	then
		[ "$quiet" -eq 0 ] && echo "[libkoca.sh] Timeout on locking. Violently exiting."
		exit 1
	else
		echo "$$" > $lock
		koca_cleanOnExit $lock
		return 0
	fi
}
function koca_unlockMe { # unlock
	rm -f "$1"
	[ ! -e "$1" ]
}
# Retourne 1 si le script a été locké par le fonction ci-dessus
# Retourne 0 sinon
function koca_isLocked {
	lock="$1"
	[ -e "$lock" ] && return 0
	return 1
}
function koca_quotemeta { # Escape meta character
	local s="$1"
	# Is it cheating ?
	echo "$s" | perl  '-ple$_=quotemeta'
}
function s2dhms {	# seconds to day hour min sec, or xx:xx:xx if -I. Return NaN or Oor if error
	if [ "$1" == '-I' ]
	then
		FORMAT='I'
		shift
	else
		FORMAT='S'
	fi
	w=$1
	[ -z "$w" ] && read w
	if ! [[ $w =~ ^[0-9]+$ ]]
	then
		echo '    NaN    '
		return
	fi
	if [ "$FORMAT" == "I" -a $w -ge 8640000 ]
	then
		echo '    OoR    '
		return
	fi
	dw=$(echo "$w/86400" | bc)   # Day Warning
	w=$(echo "$w%86400" | bc)
	hw=$(echo "$w/3600" | bc)
	w=$(echo "$w%3600" | bc)
	mw=$(echo "$w/60" | bc)
	w=$(echo "$w%60" | bc)
	case $FORMAT in
		S) 
			sdw=$([ $dw -ne 0 ] && echo "${dw}d")    # String Day Warning
			shw=$([ $hw -ne 0 ] && echo "${hw}h")
			smw=$([ $mw -ne 0 ] && echo "${mw}min")
			sw=$([ $w -ne 0 ] && echo "${w}s")
			z_tot='0s'
			;;
		I)
			sdw=$(printf "%02d:" ${dw})
			shw=$(printf "%02d:" ${hw})
			smw=$(printf "%02d:" ${mw})
			sw=$(printf "%02d" ${w})
			z_tot='00:00:00'
			;;
	esac
	tot=${sdw}${shw}${smw}${sw}
	if [ -z "$tot" ]
	then
		echo $z_tot
	else
		echo $tot
	fi
}
#http://is.gd/qQc5ab
function koca_spin {	# Display a spinning cursor
	koca_spin=(/ - \\ \| / - \\ \| ) 
	printf "\b"${koca_spin[$koca_spin_pos]} 
    (( koca_spin_pos=(koca_spin_pos +1)%8 ))
}
function whereAmI {
	pushd . >/dev/null
	cd $(dirname "$0")
	pwd
	popd > /dev/null
}
# Search a given file in path. If not found, search in common locations
# return true and the full path if found
# else return false
function whereIs {
	local w=$(type -p "$1")
	[ -n "$w" ] && echo $w && return 0
	[ -e "$1" ] && echo $1 && return 0
	for path in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /usr/libexec /usr/local/libexec
	do
		[ -e "$path/$1" ] && echo "$path/$1" && return 0
	done
	false
}
# Parenthese guarantee that my variables won't pollute the calling shell
_outdated lockMe koca_lockMe
_outdated cleanOnExit koca_cleanOnExit
(

me=$(basename -- "$0")
# libkoca.sh will be replaced by the filename
libname='libkoca.sh'
# exit if I'am sourced from a shell
[ "$me" == "$libname" ] || exit 0
here=$(cd $(dirname "$0") ; pwd)
# full path to me
fp2me=${here}/$me
if [ $# -eq 0 ]
then
    echo "$me "
    echo "Librairy of useful functions to import in a shell script"
    echo
    echo "Import all the functions :"
    echo " $ . $me"
    echo "List all the functions that can be imported :"
    echo " $ $me list"
    echo "Import only some functions :"
	echo " $ eval \"\$(sh $me function [ function [ ... ] ])\""
	echo " Don't forget \" around !"
    exit
fi
[ "$1" == "list" ] && grep -E '^function' $0 | sed -e 's/function *//' -e 's/{\(\)//g' && exit
while [ "$1" != "" ]
do
	# Print code of the function
	# plus linking
	[ "$(type -t $1)" == "function" ] && type -a $1 | sed -e "s#__libkoca__#$fp2me#g" | tail -n +2
	shift
done
)
