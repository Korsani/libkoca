#!/usr/bin/env bash
# $Id:	koca_lockMe.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
#source $here/../libs/cleanOnExit.sh
# assert <message> <valeur voulue> <valeur retournée>
export lock=/tmp/$$
TMPDIR=${TMPDIR:=/tmp}
testSW() {
	koca_stopwatch stop ; r=$?
	assertEquals "Stop without start" "$r" "2"
	koca_stopwatch start ; koca_stopwatch stop >/dev/null
	[ -z "$koca_stopwatch_start" ] ; r=$?
	assertTrue "koca_stopwatch_start not unset" "$r"
	koca_stopwatch start ; sleep 1 ; d=$(koca_stopwatch stop)
	[ "$d" -gt 1000 ] && [ "$d" -lt 1100 ] ; r=$?
	assertTrue "Stopwatch result out of bounds" "$r"
}
testSWNested() {
	startSkipping
	koca_stopwatch start sw1
	koca_stopwatch start sw2
	sleep 1
	sw2=$(koca_stopwatch stop sw2)
	sleep 1
	sw1=$(koca_stopwatch stop sw1)
	endSkipping
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
