#!/usr/bin/env bash
# $Id:	koca_lockMe.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
#source $here/../libs/cleanOnExit.sh
# assert <message> <valeur voulue> <valeur retournée>
export lock=/tmp/$$
TMPDIR=${TMPDIR:=/tmp}
testSpin() {
	startSkipping
	endSkipping
	# testing visual stuff, uh?
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
