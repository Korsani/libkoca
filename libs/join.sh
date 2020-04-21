#!/usr/bin/env bash
function koca_join { # join lines from STDIN with $1. Usage: | $0 <string>
	# Usefulness of this very function is questionable...
	cat | paste -s -d"$1" -
}
