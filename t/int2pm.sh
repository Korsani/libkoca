#!/usr/bin/env bash
# $Id: getColor.sh 1164 2013-01-08 10:15:48Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testReturnGoodResults() {
	assertEquals "10+" "+" "$(int2pm 10 100)"
	assertEquals "32+" "+" "$(int2pm 32 100)"
	assertEquals "34++" "++" "$(int2pm 34 100)"
	assertEquals "75+++" "+++" "$(int2pm 75 100)"
	assertEquals "100+++" "+++" "$(int2pm 100 100)"
	assertEquals "-75---" "---" "$(int2pm -75 100)"
	assertEquals "-34--" "--" "$(int2pm -34 100)"
	assertEquals "-32-" "-" "$(int2pm -32 100)"
	assertEquals "-10-" "-" "$(int2pm -10 100)"
	assertEquals "Zero" "~" "$(int2pm 0 10)"
	assertEquals "++++" "++++" "$(int2pm 100 100 4)"
	assertEquals "pppp" "pppp" "$(int2pm 100 100 4 "" pm)"
	assertEquals "+---------" "+---------" "$(int2pm 9 100 10 gauge)"
}
testReturnFalseOnBadParams() {
	assertFalse "Should have returned false" $(int2pm a 10 2>/dev/null)
	assertFalse "Should have returned false" $(int2pm 10 a 2>/dev/null)
	assertFalse "Base should be greater thant value" $(int2pm 100 10 2>/dev/null)
	assertFalse "Base should be >0" $(int2pm 100 -10 2>/dev/null)
	assertFalse "Scale should be < base " $(int2pm 1 3 4 2>/dev/null)
	assertFalse "Gauge doesn't accept negative numbers" $(int2pm -10 100 10 gauge 2>/dev/null)
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
