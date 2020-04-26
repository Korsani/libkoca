#!/usr/bin/env bash
# Parenthese guarantee that my variables won't pollute the calling shell
_dump_function() {
	fct="$1"
	me="$(basename -- "$0")"
	here="$(dirname "$0")"
	# full path to me
	fp2me="${here}/$me"
	if [ "$(type -t "$fct")" == "function" ]
	then
		type -a "$fct" | sed -e "s#__libkoca__#$fp2me#g" | tail -n +2
	else
		printf '"%s" is not a valid function\n' "$fct">&1
		return 2
	fi
}
_show_version() {
	printf 'version:%s-%s\n' '%VERSION%' '%BRANCH%'
}
_show_help() {
    echo "Librairy of useful functions to import in a shell script"
	echo
    echo "Import all the functions :"
    echo " $ . $me"
    echo "List all the functions that can be imported :"
    echo " $ $me list"
    echo "Import only some functions :"
	echo " $ eval \"\$(bash $me function [ function [ ... ] ])\""
	echo " Don't forget \" around !"
}
_list_functions() {
	grep -E '^function' "$0" | sed -e 's/function *//' -e 's/{\(\)//g'
}
(

# __libname__ will be replaced by the filename
libname='__libname__'
# exit if I'am sourced from a shell
if [ $# -eq 0 ]
then
	_show_help
    exit
fi
while [ -n "$1" ]
do
	case "$1" in
		list)	_list_functions;exit;;
		help)	_show_help;exit;;
		version)	_show_version;exit;;
		*)		_dump_function "$1";;
	esac
	shift
done
)
