#!/usr/bin/env bash
function koca_stopwatch {	# Provide a stopwatch
	local opt; opt="$1"
	local date
	case "$(uname -s)" in
		Linux)		date="date";;
		FreeBSD)	date="gdate";;
	esac
	if ! $date --version | grep -q GNU ; then
		return 1
	fi
	local duration=''
	case "$opt" in
		start)	koca_stopwatch_start="$($date +%s%N)";;
		stop)
			if [ -z "$koca_stopwatch_start" ] ; then
				return 2
			fi
			duration=$(( ( $($date +%s%N) - koca_stopwatch_start ) / 1000000 ));;
	esac
	if [ -n "${duration}" ] ; then
		unset koca_stopwatch_start
		echo "$duration"
	fi
}
