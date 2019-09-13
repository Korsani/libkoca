# Return true is load is less or equal to value
function koca_load() { # Return true if load is less or equals to specified float value
	thr=$1
	# Shamelessly stolen from: https://bash.cyberciti.biz/monitoring/monitor-unix-linux-system-load/
	OS="$(uname)"
	TRUE="1"
	if [ "$OS" == "FreeBSD" ]; then
		FTEXT='load averages:'
	elif [ "$OS" == "Linux" ]; then
		FTEXT='load average:'
	fi
	if [[ $thr =~ ^-?0?[1-9]*\.?[0-9]*$ ]]
	then
		# Uptime is cross-plateform. cat /proc/loadavg is not
		# LANG=C make '.' the decimal separator
		return  $(bc <<< "$(LANG=C uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f1) > $1")
	else
		echo "[__libname__] '$1' is not a float or int" >&2
		return 2
	fi
}
