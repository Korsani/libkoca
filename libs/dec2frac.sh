function koca_dec2frac {	# Return fraction form of a decimal number. Usage: $0 <float>
	local n=$1
	local PRECISION=100
	# Choose the gnu bc
	declare -A bc
	bc['Linux']='/usr/bin/bc'
	bc['Darwin']='/usr/bin/bc'
	bc['FreeBSD']='/usr/local/bin/bc'
	os=$(uname)
	${bc[$os]} --version | grep -q 'Free Software' || (echo 'Not GNU bc' && exit)
	num=$(echo "
	precision=$PRECISION
	define int(x) {
		auto s
		s = scale
		scale = 0
		x /= 1
		scale = s
		return (x)
	}
	n=$n
	scale=l(precision)/l(10)
	for (i=2;i<=precision-1;i++) {
		in=int(i*n)
		if (int(i*n+1/precision)>in) {
			print 1+in,\"/\",i
			break
		} else if (in==i*n) {
			print in,\"/\",i
			break
		}
	}" | ${bc[$os]} -l)
	if [ -n "$num" ]
	then
		echo "$num"
	else
		/bin/false
	fi
	return
}
