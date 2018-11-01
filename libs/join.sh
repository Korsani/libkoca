function koca_join { # join lines from STDIN with $1
	cat | sed -e ":a;N;\$!ba;s/\n/$1/g"
}
