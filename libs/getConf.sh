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
