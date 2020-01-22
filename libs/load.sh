# Return true is load is less or equal to value
function koca_load() { # Return true if load is less or equals to specified float value
	thr=$1
	# Shamelessly stolen from: https://bash.cyberciti.biz/monitoring/monitor-unix-linux-system-load/
	OS="$(uname)"
	declare -A ftext
	ftext['FreeBSD']='load averages:'
	ftext['Linux']='load average:'
	ftext['Darwin']='load average:'
	if [[ $thr =~ ^-?0?[1-9]*\.?[0-9]*$ ]]
	then
		# Uptime is cross-plateform. cat /proc/loadavg is not
		# LANG=C make '.' the decimal separator
		u=$(LANG=C uptime | perl -ne 's/.*: (\d+\.\d+).*/$1/;print')
		return $(echo "$u > $1"|bc) 
	else
		echo "[__libname__] '$1' is not a float or an int" >&2
		return 2
	fi
}
