#!/usr/bin/env bash
# $Id: getColor.sh 1164 2013-01-08 10:15:48Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testReturnGoodResults() {
	assertEquals "10+" "+" "$(koca_int2pm 10 100)"
	assertEquals "32+" "+" "$(koca_int2pm 32 100)"
	assertEquals "34++" "++" "$(koca_int2pm 34 100)"
	assertEquals "50++" "++" "$(koca_int2pm 50 100)"
	assertEquals "75+++" "+++" "$(koca_int2pm 75 100)"
	assertEquals "100+++" "+++" "$(koca_int2pm 100 100)"
	assertEquals "-75---" "---" "$(koca_int2pm -75 100)"
	assertEquals "-34--" "--" "$(koca_int2pm -34 100)"
	assertEquals "-32-" "-" "$(koca_int2pm -32 100)"
	assertEquals "-10-" "-" "$(koca_int2pm -10 100)"
	assertEquals "Zero" "~" "$(koca_int2pm 0 10)"
	assertEquals "++++" "++++" "$(koca_int2pm 100 100 4)"
	assertEquals "pppp" "pppp" "$(koca_int2pm 100 100 4 "" pm)"
	assertEquals "+---------" "+---------" "$(koca_int2pm 9 100 10 gauge)"
	assertEquals "1" "+" "$(koca_int2pm 1)"
	assertEquals "2" "++" "$(koca_int2pm 2)"
	assertEquals "3" "+++" "$(koca_int2pm 3)"
}
testReturnFalseOnBadParams() {
	assertFalse "Should have returned false" $(koca_int2pm a 10 2>/dev/null)
	assertFalse "Should have returned false" $(koca_int2pm 10 a 2>/dev/null)
	assertFalse "Max should be greater than value" $(koca_int2pm 100 10 2>/dev/null)
	assertFalse "Max should be greater than 0" $(koca_int2pm 100 -10 2>/dev/null)
	assertFalse "Gauge doesn't accept negative numbers" $(koca_int2pm -10 100 10 gauge 2>/dev/null)
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
