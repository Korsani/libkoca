#!/usr/bin/env bash
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
function koca_cleanOnExit { # Remove specified file on script exit. Usage: $0 <file>
	local file
	for file in "$@" ; do
		local t ; t=$(trap -p 0)
		[ -n "$t" ] && _oldTrap0=$(echo "$t ;" | sed -e "s/trap -- '\(.*\)' EXIT/\1/")
		trap "$_oldTrap0 rm -f \"$file\"" 0
	done
}
#!/usr/bin/env bash
function koca_dec2frac {	# Return fraction form of a decimal number. Usage: $0 <float>
	local n=$1
	local PRECISION=100
	# Choose the gnu bc
	declare -A bc
	bc['Linux']='/usr/bin/bc'
	bc['Darwin']='/usr/local/opt/bc/bin/bc'
	bc['FreeBSD']='/usr/local/bin/bc'
	os=$(uname)
	${bc[$os]} --version | grep -q 'Free Software' || (echo 'Not GNU bc' && exit)
	num=$(echo "
	precision=$PRECISION
	define int(x) {
		auto s
		s = scale
		scale = 0
		x /= 1
		scale = s
		return (x)
	}
	n=$n
	scale=l(precision)/l(10)
	for (i=2;i<=precision-1;i++) {
		in=int(i*n)
		if (int(i*n+1/precision)>in) {
			print 1+in,\"/\",i
			break
		} else if (in==i*n) {
			print in,\"/\",i
			break
		}
	}" | ${bc[$os]} -l)
	if [ -n "$num" ] ; then
		echo "$num"
	else
		/bin/false
	fi
	return
}
#!/usr/bin/env bash
function dhms2s {	# Convert a 'day hour min sec' string to seconds. Usage: $0 <string>
	# can be specified in any order :
	# 1d1s is the same as 1s1d
	local w; w="$1"
	[ -z "$w" ] && read -r w
	local op ; op="$(echo "$w" | sed -e 's/\([0-9]*\)y/\1*31556952 + /' -e 's/\([0-9]*\)d/\1*86400 + /' -e 's/\([0-9]*\)h/\1*3600 + /' -e 's/\([0-9]*\)min/\1*60 + /' -e 's/\([0-9]*\)s/\1 + /' -e 's/+ $//' -e 's/$/+0/' | sed -e 's/  /0/')"
	if [[ $op =~ ^[0-9.\+\ \*]+$ ]] ; then
		echo "$op" | bc
	else
		echo '-1'
	fi
}
#!/usr/bin/env bash
function dieIfNotRoot { # Exit calling script if not running under root. Usage: $0
	local src ; src=__libkoca__ ; [ -e $src ] && eval "$(bash $src gotRoot)"
	! gotRoot && echo "[__libname__] Actually, I should be run as root" && exit 1
	#! underSudo && echo "[__libname__] Actually, I should be run under sudo" && exit 1
	return 0
}
function dieIfRoot { # Exit calling script if run under root
	local src ; src=__libkoca__ ; [ -e $src ] && eval "$(bash $src gotRoot)"
	gotRoot && echo "[__libname__] I should not be run as root" && exit 1
	#underSudo && echo "[__libname__] I should not be run under sudo" && exit 1
	return 0
}
function underSudo { # Return wether the calling script is run under sudo
	[ -n "$SUDO_USER" ]
}
function gotRoot { # Return wether the calling script is run under root
	[ "$(id -u)" -eq 0 ]
}
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
#!/usr/bin/env bash
_getConfGetSedOption() {
	local opt
	case $(uname -s) in
        Darwin|FreeBSD)	opt='E' ;;
        OpenBSD)        opt='';;
        Linux|*)		opt='r' ;;
    esac
	echo $opt
}
_getConfIsReadable() {
	# Sauf qu'un fichier est toujours lisible par root, même s'il 
	# a le mode 0000 ...
	local flag=1
	for file in $KOCA_CONF ; do
		# At least one is readable
		[ -r "$file" ] && flag=0
	done
	[ $flag -eq 1 ] && echo "[libkoca] No readable conf file provided. Please put one in an env var named 'KOCA_CONF'" >&2 && return 1
	[ $flag -eq 0 ] && return 0
	return 2
}
# Deprecated
getConf() {
	echo "[__libname__] Please use getConfValue" >&2
	echo "$(date -u +%Y%m%d%H%M%SZ) : $(cd "$(dirname \"$0\")" ; pwd)/$(basename \"$0\") : getConf" >> /var/libkoca/stats
	getConfValue "$*"
}
# Return values from a configuration file passed in $KOCA_CONF variable
# format of conf file : section.key=value
# Usage : getConfValue <section> <key>
function getConfValue {	# Get a the value corresponding to a key from a conf file. Usage: $0 <key>
## link: ## _getConfGetSedOption ##
## link: ## _getConfIsReadable ##
	# hey hey, dynamic linking :)
	# If included in a script, nothing is done
	# If get by eval, then get those 2 functions
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" _getConfGetSedOption _getConfIsReadable)"
	local opt ; opt="$(_getConfGetSedOption)"
	_getConfIsReadable || return $?
	local val ; val="$(grep -Eh "^$1\.$2[[:space:]]*=" "$KOCA_CONF" 2>/dev/null | sed -${opt}e 's/[^=*]+=[[:space:]]*//'| tail -1)"
	[ -n "$val" ] && echo "$val" && return 0
	[ -n "$3" ] && echo "$3" && return 0
	return 2
}
# Return of the keys of a specified section
# Usage : getConfAllKeys <section>
function getConfAllKeys {
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" _getConfGetSedOption _getConfIsReadable)"
	local opt ; opt=$(_getConfGetSedOption)
	_getConfIsReadable || return $?
	local val ; val="$(grep -Eh "^$1\." "$KOCA_CONF" | sed -e "s/^$1\.\(.*\)\s*=.*/\1/" | xargs)"
	[ -n "$val" ] && echo "$val" && return 0
	return 2
}
# Return all the sections of an eventulally given keys
# Usage : getConfAllSections [ <key> [ <key> [ ... ] ]
function getConfAllSections {
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" _getConfGetSedOption _getConfIsReadable)"
	local opt ; opt="$(_getConfGetSedOption)"
	_getConfIsReadable || return $?
	local v
	if [ -z "$1" ] ; then
		v="$(grep -Eh "^[^[:space:]#].*\..*[\.\s=]" "$KOCA_CONF" | sed -e "s/^\(.*\)\..*\s*=.*/\1/" | sort -u | xargs)"
    else
		while [ -n "$1" ] ; do
			v="$v $(grep -Eh "^[^[:space:]#].*\.$1[\.\s=]" "$KOCA_CONF" | sed -e "s/^\(.*\)\..*\s*=.*/\1/" | sort -u | xargs)"
			shift
		done
    fi
	echo "$v" | xargs
}
#!/usr/bin/env bash
# Return the number converted in +/- scale
function koca_int2pm { # return +, ++, +++ (or -). Usage: $0 <value> [ <max> [ <length> [ 'gauge' [ <sign+><sign-> ] ] ] ]
	local val="$1"
	local MAX=3
	local LENGTH=3
	local SIGNS='+-'
	local GAUGE=''
	[ -n "$5" ] && SIGNS="$5"
	[ -n "$3" ] && LENGTH="$3"
	[ -n "$2" ] && MAX="$2"
	[ "$4" == "gauge" ] && GAUGE="y"
	
	if ! ( [[ $MAX =~ ^[0-9]+$ ]] && [[ $val =~ ^-?[0-9]+$ ]] && [[ $LENGTH =~ ^[0-9]+$ ]]) ; then
		echo "[${FUNCNAME[0]}] Params should be integers" >&2
		return 1
	fi
	if [ "$MAX" -lt 0 ] ; then
		echo "[${FUNCNAME[0]}] Max ($MAX) should be positive" >&2
		return 3
	fi
	if [ -n "$GAUGE" ] && [ "$val" -lt 0 ] ; then
		echo "[${FUNCNAME[0]}] Value ($val) must be positive when using gauge" >&2
		return 3
	fi
	if [ "$MAX" -lt "$val" ] ; then
		echo "[${FUNCNAME[0]}] Max ($MAX) should be greater than value ($val)" >&2
		return 2
	fi
	if [ "$val" -lt 0 ] ; then
		sign=${SIGNS:1:1}
	else
		sign=${SIGNS:0:1}
	fi
	if [ "$val" -eq "$MAX" ] ; then
		printf "%0.s$sign" {$(seq 1 "$LENGTH")}
		echo
		return 0
	fi
	if [ "$val" -eq 0 ] ; then
		r='~'
	else
		# Weird ?
		n="$(echo "scale=2;r=$val/($MAX/$LENGTH)*$val/sqrt($val^2); if (r>$LENGTH) r=$LENGTH; r" | bc )"
		# Fucking bc that is not able to say me wether a number is integer or not ...
		if [[ $n =~ .00$ ]] ; then
			n="$(echo "$n" | cut -d '.' -f 1)"
		else
			n="$(($(echo "$n" | cut -d '.' -f 1)+1))"
		fi
		r="$(printf "%0.s$sign" {$(seq 1 $n)})"
		if [ -n "$GAUGE" ] ; then
			if [ "$n" -ne "$LENGTH" ] ; then
				r+="$(printf "%0.s${SIGNS:1:1}" {$(seq $((n+1)) "$LENGTH")})"
			fi
		fi
	fi
	echo "$r"
}
#!/usr/bin/env bash
function koca_isBackgrounded() { # Return true if process is backgrounded. Usage: $0
	# Thanks to http://is.gd/4h3fk0.
	case $(ps -o stat= -p $$) in
		*+*) return 1;;
		*) return 0;;
esac
}
#!/usr/bin/env bash
#!/usr/bin/nev bash
function koca_isNumeric { # Return true if parameter is numeric. Usage: $0 <string>
	[[ $1 =~ ^[+-]*[0-9.]+$ ]]
}
#!/usr/bin/env bash
function koca_join { # join lines from STDIN with $1. Usage: | $0 <string>
	# Usefulness of this very function is questionable...
	cat | paste -s -d"$1" -
}
#!/usr/bin/env bash
# Fournit un mechanisme de lock: empeche plusieurs instances 
# de tourner en meme temps.
# Efface le lock s'il est vide, ou s'il ne correspond vraisemblablement pas au processus qui essait de le créer
# Utilisation:
# lockMe [ -q ] <fichier de lock> [ timeout ]
# -q : sort silencieusement si le timeout expire
# PS: le fichier ne devrait pas etre un `mktemp`, sinon ca risque pas de marcher cm prevu :)
function koca_lockMe { # Lock the calling script with the specified file. Usage: $0 <file>
	local src=__libkoca__ ; [ -e "$src" ] && eval "$(bash "$src" koca_cleanOnExit)"
	local quiet=0
	local lock
	[ "$1" = "-q" ] && quiet=1 && shift
	if [ -z "$1" ] ; then
		lock="/tmp/$(basename "$0").lock"
	else
		lock="$1"
	fi
	local to ; to=60
	[ -n "$2" ] && to="$2"
	local n ; n=0
	if [ -s "$lock" ] ; then
		# replace the shell by its absolute path (bash -> /bin/bash)
		c="$(ps -o command=COMMAND $(cat "$lock") | grep -v COMMAND | awk '{print $2}' | xargs echo $SHELL )"
		# Should detect that /bin/bash plop.sh is the same as /bin/bash ./plop.sh
		if [[ ! "$c" =~ $SHELL" "\.?\/?$0.* ]] ; then
			[ "$quiet" -eq 0 ] && echo "[__libname__] Stall lock ($c vs $SHELL $0). Removing."
			rm -f "$lock"
		fi
	else
		if [ -e "$lock" ] ; then
			echo "[__libname__] Empty lock $lock. Removing"
			rm -f "$lock"
		fi
	fi
	while [ -e "$lock" ] && [ "$n" -le "$to" ] ; do
		[ "$quiet" -eq 0 ] && echo "[__libname__] An instance is running (pid : $(/bin/cat "$lock"))."
		[ "$(basename -- "$0")" == "bash" ] && return
		[ "$to" -eq 0 ] && exit 1
		sleep 1
		(( n++ ))
		# boucler plutot que sortir ?
	done
	if [ "$n" -gt "$to" ] && [ -e "$lock" ] ; then
		[ "$quiet" -eq 0 ] && echo "[__libname__] Timeout on locking. Violently exiting."
		exit 1
	else
		echo "$$" > "$lock"
		koca_cleanOnExit "$lock"
		return 0
	fi
}
function koca_unlockMe { # Remove the lock. Usage: $0 <file>
	rm -f "$1"
	! [ -a "$1" ]
}
# Retourne 1 si le script a été locké par le fonction ci-dessus
# Retourne 0 sinon
function koca_isLocked {	# Check wether lock exists
	local lock="$1"
	[ -a "$lock" ] && return 0
	return 1
}
#!/usr/bin/env bash
#http://is.gd/qQc5ab
function koca_spin {	# Display a spinning cursor or scrolling text. Usage: $0 [ <int|string> [ <-1|0|1> [ <int> ] ] ]. $0 list
	local spin=${1:-0}
	local dir=${2:-1}
	local length=${3:-1}
	local demo
	declare -A koca_spin ; local koca_spin
	koca_spin[0]='/-\|/-\|'
	koca_spin[1]='|>=<|<=>'
	koca_spin[2]='O○·○'
	koca_spin[3]='[{(|)}]'
	koca_spin[4]='.oOo'
	koca_spin[5]='⡆⠇⠋⠙⠸⢰⣠⣄'
	koca_spin[6]='⡀⠄⠂⠁⠈⠐⠠⢀'
	koca_spin[7]='⠉⠒⠤⣀⣉⣒⣤⣭⣶⣿⠿⣛⠛⠭⣉⠉⠒⠤⣀ '
	case $spin in
		[0-9]) ;;
		list) for n in ${!koca_spin[*]} ; do echo "$n:${koca_spin[$n]}" ; done ; return ;;
		demo) demo="$dir";;
		*) koca_spin[0]="$1" ; spin=0 ;;
	esac
	if [ -n "$demo" ] ; then
		while true ; do
			koca_spin "$demo" ; sleep 0.5
		done
		return
	fi
	if [ "$length" -gt ${#koca_spin[$spin]} ] ; then
		echo "[__libname__] Length ($length) must not be greater than the string length (${#koca_spin[$spin]})" >&2
		return 1
	fi
	if ! [[ $dir =~ [01$] ]] ; then
		echo "[__libname__] Direction must be -1, 0 or 1, not $dir" >&2
		return 1
	fi
	[ $spin -ge ${#koca_spin[*]} ] && spin=0
	declare -a index ; local index
	# Make equation easier to write
	local a=$dir ; local n=${#koca_spin[$spin]}-$length
	[ "$dir" -eq 0 ] && a=1	# Deal with that case later
	# Build index of position from where to write
	# Nii... Make first term to 0 when a=1, n when a=-1
	index=( $(seq $((a*n*(a-1)/2)) $a $((n-a*n*(a-1)/2)) ) )
	if [ "$dir" -eq 0 ] ; then		# Bouncing: generate the same sequence, backward, starting from n-1, till 1 (as sequence start with 0)
		index=( ${index[@]} $(seq $((n-1)) -1 1) )
	fi
	# Display $length car, starting from somewhere
	printf "\r%s" "${koca_spin[$spin]:${index[$koca_spin_pos]}:$length}"
	# Moving forward in index
	(( koca_spin_pos=(koca_spin_pos+1)%${#index[@]} ))
	# Mmm...
	return 0
}
#!/usr/bin/env bash
function koca_verscmp {	# version comparison
	local v1="$1"
	local op="$2"
	local v2="$3"
	v1=${v1/v/} ; v2=${v2/v/}
	case "$op" in
		ge) [ "$(printf '%s\n%s' "$v1" "$v2" | sort --version-sort | tail -1 )" == "$v1" ] || [ "$v1" == "$v2" ];;
		gt) [ "$(printf '%s\n%s' "$v1" "$v2" | sort --version-sort | tail -1 )" == "$v1" ] && [ "$v1" != "$v2" ];;
		eq) [ "$v1" == "$v2" ];;
		le) [ "$(printf '%s\n%s' "$v1" "$v2" | sort --version-sort | head -1 )" == "$v1" ] || [ "$v1" == "$v2" ];;
		lt) [ "$(printf '%s\n%s' "$v1" "$v2" | sort --version-sort | head -1 )" == "$v1" ] && [ "$v1" != "$v2" ];;
		*)  /bin/false;;
	esac
}
#!/usr/bin/env bash
function whereAmI {	# Return the directory where the script reside. Usage: $0
	pushd . >/dev/null
	cd "$(dirname "$0")"
	pwd
	popd > /dev/null
}
#!/usr/bin/env bash
# Search a given file in path. If not found, search in common locations
# return true and the full path if found
# else return false
function whereIs {	# Return the location of a given file by searching in common locations. Usage: $0 <string>
	local w ; w=$(type -p "$1")
	[ -n "$w" ] && echo "$w" && return 0
	[ -e "$1" ] && echo "$1" && return 0
	for path in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /usr/libexec /usr/local/libexec ; do
		[ -e "$path/$1" ] && echo "$path/$1" && return 0
	done
	false
}
#!/usr/bin/env bash
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
function koca_cleanOnExit { # Remove specified file on script exit. Usage: $0 <file>
	local file
	for file in "$@" ; do
		local t ; t=$(trap -p 0)
		[ -n "$t" ] && _oldTrap0=$(echo "$t ;" | sed -e "s/trap -- '\(.*\)' EXIT/\1/")
		trap "$_oldTrap0 rm -f \"$file\"" 0
	done
}
