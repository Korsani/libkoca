function koca_join { # join lines from STDIN with $1
	# Usefulness of this very function is questionable...
	cat | paste -s -d"$1" -
}
