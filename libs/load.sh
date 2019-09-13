# Return true is load is less or equal to value
function koca_load() { # Return true if load is less or equals to specified float value
	thr=$1
	if [[ $thr =~ ^-?0?[1-9]*\.?[0-9]*$ ]]
	then
		return  $(bc <<< "$(cat /proc/loadavg | cut -d ' ' -f 1) > $1")
	else
		echo "[__libname__] '$1' is not a float or int" >&2
		return 2
	fi
}
