#!/usr/bin/env bash
# $Id: getConf.sh 1149 2012-12-10 02:52:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
# assert <message> <valeur voulue> <valeur retournée>
TMPDIR=${TMPDIR:=/tmp}
setUp() {
	export KOCA_CONF="$(mktemp)"
	export KOCA_CONF_TOO="$(mktemp)"
	echo 'global.ssh=plop' > "$KOCA_CONF"
}
tearDown() {
	rm -f "$KOCA_CONF" "$KOCA_CONF_TOO"
}
testGetconfReturnCorrectValues() {
	val=$(getConfValue global ssh)
	ret=$?
	assertEquals "getConfValue doesn't return value" 'plop' "$val"
	assertTrue "getConfValue doesn't return true" "$ret"
}
testGetconfReturnFalseonUnfoundConfFile() {
	val=$(KOCA_CONF=/etc/gna getConfValue plop plop 2>&1)
	ret=$?
	assertFalse "getConfValue doesn't return false ($ret)" "$ret"
	assertEquals "getConfValue doesn't return 1 (was $ret)" "1" "$ret"
}
testGetconfReturnFalseOnNotReadableConfFile() {
	echo 'plop.gna=1' > $KOCA_CONF
	chmod a-r $KOCA_CONF
	val=$(getConfValue plop gna 2>/dev/null)
	ret=$?
	# root peut tout lire ...
	[ "$(id -u)" -eq "0" ] && ret=1
	assertFalse "getConfValue doesn't return false ($ret)" "$ret"
}
testGetconfReturn2onUnfoundEntry() {
	val=$(getConfValue plop plop)
	ret=$?
	assertFalse "getConfValue doesn't return false (was $ret)" "$ret"
	assertEquals "getConfValue doesn't return 2 (was $ret)" "2" "$ret"
}
testGetconfReturn2onCommentedEntry() {
	echo '#com.plop=gna' >> $KOCA_CONF
	val=$(getConfValue com ssh)
	ret=$?
	assertEquals "getConfValue doesn't return 2 (was $ret)" "2" "$ret"
}
testGetconfReturnCorrectValuesWhenDoubleEquals() {
	echo 'com.sshdouble=plop=gna' > $KOCA_CONF
	val=$(getConfValue com sshdouble)
	ret=$?
	assertEquals "getConfValue doesn't return correct value " "plop=gna" "$val"
}
testGetconfReturnCorrectValuesWhenTripleEquals() {
	echo 'com.sshdouble=plop=gna=bou' >> $KOCA_CONF
	val=$(getConfValue com sshdouble)
	ret=$?
	assertEquals "getConfValue doesn't return correct value " "plop=gna=bou" "$val"
}
testGetconfCorrectlyHandleSpaces() {
	echo 'com.sshspace = plop = gna' > $KOCA_CONF
	val=$(getConfValue com sshspace)
	ret=$?
	assertEquals "getConfValue doesn't return correct value $val " "plop = gna" "$val"
}
testGetconfReturneLastKeyOnDoubleKeys() {
	echo 'com.sshdouble=plop=one' > $KOCA_CONF
	val=$(getConfValue com sshdouble)
	ret=$?
	assertEquals "getConfValue doesn't return correct value $val" "plop=one" "$val"
}
testGetconfReturnFalseIfConfVarNotProvided() {
	val=$(KOCA_CONF="" getConfValue plop gna 2>/dev/null)
	ret=$?
	assertEquals "getConfValue should return 1" "1" "$ret"
}
testGetconfReturnFalseIfConfFileDoesntExists() {
	val=$(KOCA_CONF=$RANDOM getConfValue plop gna 2>/dev/null)
	ret=$?
	assertEquals "getConfValue should return 1" "1" "$ret"
}
testGetconfReturnOneResultOnAmbiguousRequest() {
	echo 'com.ssh1=one' > $KOCA_CONF
	echo 'com.ssh2=one' >> $KOCA_CONF
	val=$(getConfValue com ssh)
	assertFalse "getConfValue should return false" "$ret"
}
testGetconfReturnAllTheIndexOfASection() {
	echo 'com.ssh1=one' > $KOCA_CONF
	echo 'com.ssh2=one' >> $KOCA_CONF
	val="$(getConfAllKeys com| xargs)"
	assertEquals "Not all values have been returned" "ssh1 ssh2" "$val"
}
testGetconfReturnAllTheSections() {
	echo 'com1.ssh1=one' > $KOCA_CONF
	echo 'com2.ssh2=one' >> $KOCA_CONF
	echo 'com1.ssh2=*' >> $KOCA_CONF
	echo '# toupidou.plop=one' >> $KOCA_CONF
	echo ' # toupidou.plop=one' >> $KOCA_CONF
	echo '  # toupidou.plop=one' >> $KOCA_CONF
	sections="$(getConfAllSections| xargs)"
	assertEquals "Not all sections have been returned" "com1 com2" "$sections"
}
testGetconfCorrectlyHandleStars() {
	echo 'a.b=*' > $KOCA_CONF
	v=$(getConfValue a b)
	assertEquals "Wrong handling of stars" '*' "$v"
}
testGetconfCorrectlyHandleThirdParameter() {
	echo 'a.b=2' > $KOCA_CONF
	v="$(getConfValue a c 1)"
	assertEquals "Do not correctly handle third parameter" '1' "$v"
}
testGetconfReturnAllSectionsOfProvidedKey() {
	echo 's1.k=1' >$KOCA_CONF
	echo 's2.k=2' >>$KOCA_CONF
	echo 's3.kk=2' >>$KOCA_CONF
	echo 's4.a-k=2' >>$KOCA_CONF
	v="$(getConfAllSections k|xargs)"
	assertEquals "Ploup" 's1 s2' "$v"
	v="$(getConfAllSections k kk|xargs)"
	assertEquals "Ploup" 's1 s2 s3' "$v"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
