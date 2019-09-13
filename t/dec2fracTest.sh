#!/usr/bin/env bash
# $Id: getColor.sh 1164 2013-01-08 10:15:48Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testReturnGoodResults() {
	assertEquals "1.5" "3/2" "$(koca_dec2frac 1.5)"
	assertEquals "1.2" "6/5" "$(koca_dec2frac 1.2)"
	assertEquals "0.7" "7/10" "$(koca_dec2frac 0.7)"
	assertEquals "Frac" "1/3" "$(koca_dec2frac 0.3333333333333333333333333)"
	assertEquals "Precision" "49/69" $(koca_dec2frac 0.71)
	assertEquals "16/9" "16/9" $(koca_dec2frac 1.77777777)
	assertFalse "Precision" $(koca_dec2frac 0.7168687687687678)
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
