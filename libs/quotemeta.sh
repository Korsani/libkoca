function koca_quotemeta { # Escape meta character. Usage: $0 <string>
	local s="$1"
	# Is it cheating ?
	echo "$s" | perl  '-ple$_=quotemeta'
}
