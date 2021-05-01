#!/usr/bin/env bash
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
# assert <message> <valeur voulue> <valeur retournée>
TMPDIR=${TMPDIR:=/tmp}
testVersionCompare() {
	koca_verscmp 2.0.0 gt 1.0.0 ; _ec=$? ; assertTrue "gt 1" $_ec
	koca_verscmp 2.0.0 gt 1.0.0.120 ; _ec=$? ; assertTrue "gt 2" $_ec
	koca_verscmp 2.0.0 ge 1.0.0 ; _ec=$? ; assertTrue "ge 1" $_ec
	koca_verscmp 1.0.0 lt 2.0.0 ; _ec=$? ; assertTrue "lt 1" $_ec
	koca_verscmp 1.0.0 le 1.0.0 ; _ec=$? ; assertTrue "le 1" $_ec
	koca_verscmp 0.1.0 le 1.0.0 ; _ec=$? ; assertTrue "le 2" $_ec
	koca_verscmp 1.1.0 le 1.0.0 ; _ec=$? ; assertFalse "le 3" $_ec
	koca_verscmp 1.1.0 eq 1.0.0 ; _ec=$? ; assertFalse "eq 1" $_ec
	koca_verscmp 1.0.0 eq 1.0.0 ; _ec=$? ; assertTrue "eq 2" $_ec
	koca_verscmp v1.0.0 eq v1.0.0 ; _ec=$? ; assertTrue "eq 3" $_ec
	koca_verscmp 1.0.0 eq v1.0.0 ; _ec=$? ; assertTrue "eq 4" $_ec
	koca_verscmp 1.0.0 eql v1.0.0 ; _ec=$? ; assertFalse "false op" $_ec
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
