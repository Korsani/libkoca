#!/usr/bin/env bash
# $Id: s2dhms.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
tests2dhms()  {
	d=$(s2dhms 31556952)
	assertEquals "Seconds badly parsed" "1y" "$d"
	d=$(s2dhms 60)
	assertEquals "Seconds badly parsed" "1min" "$d"
	d=$(s2dhms 59)
	assertEquals "Seconds badly parsed" "59s" "$d"
	d=$(s2dhms 3600)
	assertEquals "Seconds badly parsed" "1h" "$d"
	d=$(s2dhms 86400)
	assertEquals "Seconds badly parsed" "1d" "$d"
	d=$(s2dhms 86401)
	assertEquals "Seconds badly parsed" "1d1s" "$d"
	d=$(s2dhms 86461)
	assertEquals "Seconds badly parsed" "1d1min1s" "$d"
	d=$(s2dhms 90061)
	assertEquals "Seconds badly parsed" "1d1h1min1s" "$d"
	d=$(s2dhms 3661)
	assertEquals "Seconds badly parsed" "1h1min1s" "$d"
	d=$(s2dhms 61)
	assertEquals "Seconds badly parsed" "1min1s" "$d"
	d=$(echo 61 | s2dhms)
	assertEquals "dhms doesn't accept dat on standard input" "1min1s" "$d"
	d=$(echo 61 | s2dhms -I)
	assertEquals "dhms does not display in international format" "00:00:00:01:01" "$d"
	d=$(s2dhms -I 61)
	assertEquals "dhms does not display in international format" "00:00:00:01:01" "$d"
	d=$(s2dhms -I 86401)
	assertEquals "dhms does not display in international format" "00:01:00:00:01" "$d"
	d=$(s2dhms plop)
	assertEquals "not a number" "    NaN    " "$d"
	d=$(s2dhms 99p)
	assertEquals "not a number" "    NaN    " "$d"
	d=$(s2dhms -I 8640000)
	assertEquals "out of range" "    OoR    " "$d"
	d=$(s2dhms -I 0)
	assertEquals "Not 00:00:00:00:00" "00:00:00:00:00" "$d"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
