#!/usr/bin/env bash
#!/usr/bin/nev bash
function koca_isNumeric { # Return true if parameter is numeric. Usage: $0 <string>
	[[ $1 =~ ^[+-]*[0-9.]+$ ]]
}
