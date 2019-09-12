# Return fraction form of a decimal number
function koca_dec2frac {
	local n=$1
	local PRECISION=100
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
	}" | bc -l)
	if [ -n "$num" ]
	then
		echo "$num"
	else
		/bin/false
	fi
	return
}
