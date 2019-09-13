#!/usr/bin/env bash
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testload() {
	koca_load a 2>/dev/null ; r=$?
	assertEquals "Load accepts non int/float" "2" "$r"
	koca_load 10 ;r=$?
	assertTrue "Load is less than 10" "$r"
	koca_load -1 ;r=$?
	assertFalse "Load is less than 0" "$r"
	koca_load 0.0 ; r=$?
	assertFalse "Load less than 0 should always be false" "$r"
	overload=$(bc <<< "$(cat /proc/loadavg | cut -d ' ' -f 1) + 0.02")
	koca_load $overload ; r=$?
	assertTrue "I should be overloaded" "$r"
	koca_load .01 ; r=$?
	assertFalse "Load should accept .xx form" "$r"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
