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
