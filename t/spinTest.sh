#!/usr/bin/env bash
# $Id:	koca_lockMe.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
#source $here/../libs/cleanOnExit.sh
# assert <message> <valeur voulue> <valeur retournée>
export lock=/tmp/$$
TMPDIR=${TMPDIR:=/tmp}
testSpin() {
	koca_spin 'a' 1 2 2>/dev/null; r=$?
	assertFalse "Should return false" "$r"
	# testing visual stuff, uh?
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
