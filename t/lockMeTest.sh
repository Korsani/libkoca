#!/usr/bin/env bash
# $Id:	koca_lockMe.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
source $here/../libs/cleanOnExit.sh
# assert <message> <valeur voulue> <valeur retournée>
export lock="/tmp/$$"
conf="/tmp/test.cfg"
TMPDIR=${TMPDIR:=/tmp}
oneTimeSetUp() {
	echo 'global.ssh=plop' > $conf
}
testLocking() {
	koca_lockMe "$lock"
	assertTrue 'Lock failed' "$?"
	koca_unlockMe "$lock"
}
testLockDetecting() {
	koca_lockMe "$lock"
	koca_isLocked "$lock"
	assertTrue 'Lock is not here. It should be' "$?"
	mv "$lock" "$lock$$"
	koca_isLocked "$lock"
	assertFalse "Unlock is here. It shouldn't" "$?"
	mv "$lock$$" "$lock"
}
testLockRemoving() {
	koca_unlockMe "$lock"
	assertTrue 'Lock is not removed' "$?"
}
testLockMeWithMultipleTrap0() {
	trap -p 0 > "/tmp/trap$$"
	trap "echo ${FUNCNAME[0]}" 0
	koca_lockMe "$lock"
	t="$(trap -p 0)"
	assertEquals 'Trap was not replaced' "trap -- 'echo ${FUNCNAME[0]} ; rm -f \"$lock\"' EXIT" "$t"
	koca_unlockMe "$lock"
	eval $(cat /tmp/trap$$)
	rm -f "/tmp/trap$$"
}
testLockMeRemoveEmptyLock() {
	touch "$lock"
	koca_lockMe "$lock" 1 ; r=$?
	assertTrue 'Failed to lock if previous lock file is empty' "[ -e $lock ]"
	koca_unlockMe "$lock"
}
testDetectLockWhenShellIsNotAnAbsolutePath() {
	local fn=$TMPDIR/plop$$
	cat <<- EOF > $fn
	#!/bin/bash
	source $(cd $(dirname "$0") ; pwd)/../libs/lockMe.sh
	source $(cd $(dirname "$0") ; pwd)/../libs/cleanOnExit.sh
	koca_lockMe /tmp/.pid
	sleep 3
	rm -f \$0
	EOF
	chmod +x "$fn"
	$fn > /dev/null &
	bash $fn | grep 'instance is running'
	#assertTrue "An instance was not detected, whereas is should be, even if shell seems different (bash vs /bin/bash)" $?
	rm -f "$fn"
}
oneTimeTearDown() {
	koca_unlockMe "$lock"
	trap 0
	rm -f "$conf"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
