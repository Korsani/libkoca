#!/usr/bin/env bash
# $Id:	koca_lockMe.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
#source $here/../libs/cleanOnExit.sh
# assert <message> <valeur voulue> <valeur retournée>
export lock=/tmp/$$
TMPDIR=${TMPDIR:=/tmp}
testBanner() {
	koca_banner 'plop' rt 2>/dev/null ; _ec=$? ; assertFalse "Did not return false upon wrong speed" $_ec
	koca_banner 'plop' 100lo 2>/dev/null ; _ec=$? ; assertFalse "Did not return false upon wrong speed" $_ec
	koca_banner 'plop' 100cp 2>/dev/null ; _ec=$? ; assertFalse "Did not return false upon wrong speed" $_ec
	koca_banner 'plop' 100cps 2>/dev/null ; _ec=$? ; assertTrue "Did not return true" $_ec
	koca_banner 'plop' 0.1cps 2>/dev/null ; _ec=$? ; assertFalse "Did not return false" $_ec
	koca_banner 'plop' 1 2>/dev/null ; _ec=$? ; assertTrue "Did not return true" $_ec
	koca_banner 'plop' 0,5 2>/dev/null ; _ec=$? ; assertTrue "Did not return true" $_ec
	koca_banner 'plop' 0.5 2>/dev/null ; _ec=$? ; assertTrue "Did not return true" $_ec
	koca_banner 'plop' .5 2>/dev/null ; _ec=$? ; assertTrue "Did not return true" $_ec
	koca_banner 'plop' 0.53 2>/dev/null ; _ec=$? ; assertTrue "Did not return true" $_ec
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
