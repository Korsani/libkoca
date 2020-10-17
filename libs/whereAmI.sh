#!/usr/bin/env bash
function whereAmI {	# Return the directory where the script reside. Usage: $0
	pushd . >/dev/null
	cd "$(dirname "$0")" || return 1
	pwd
	popd > /dev/null || return 1		# Dubious behaviour...
}
