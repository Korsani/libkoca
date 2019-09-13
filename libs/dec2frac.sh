function koca_dec2frac {	# Return fraction form of a decimal number@
	local n=$1
	local PRECISION=100
	# Choose the gnu bc
	case $(uname) in  Linux) bc=/usr/bin/bc;; FreeBSD) bc=/usr/local/bin/bc;; esac ; $bc --version | grep -q 'Free Software' || (echo 'Not GNU bc' && exit)
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
	}" | $bc -l)
	if [ -n "$num" ]
	then
		echo "$num"
	else
		/bin/false
	fi
	return
}
