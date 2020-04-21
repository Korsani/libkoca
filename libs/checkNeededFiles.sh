#!/usr/bin/env bash
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
function checkNeededFiles {	# Check wether file can be found. Usage: $0 must|may <file>
	local _ec=0
	while [ -n "$1" ]
	do
		case $1 in
			-q) 		local quiet='yes';;
			may|must)	type="$1";;
			*)
				if ! type -p "$1" >/dev/null 2>&1
				then
					[ "$type" = "may" ] && [ -z "$quiet" ] && echo "[__libname__] '$1' not found. Bad things may happen" >&2 && ((_ec++))
					[ "$type" = "must" ] && [ -z "$quiet" ] && echo "[__libname__] '$1' not found. Bad things WILL happen" >&2 && ((_ec++))
					if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
					then
						eval export $1=\"echo '$1'\"
					else
						[ -z "$quiet" ] && echo "[__libname__] Var '$1' won't be exported"
					fi
                else
					if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
					then
                    	eval export $1="$(which "$1")"
					else
						[ -z "$quiet" ] && printf "[__libname__] Var '%s' won't be exported" "$1"
					fi
				fi
				;;
		esac
		shift
	done
	return "$_ec"
}
