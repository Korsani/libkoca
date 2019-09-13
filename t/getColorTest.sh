#!/usr/bin/env bash
# $Id: getColor.sh 1164 2013-01-08 10:15:48Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
tput_af="setaf"
tput_ab="setab"
bold=bold
reset=sgr0
if [ "$(uname)" = "FreeBSD" ]
then
	tput_af=AF
	tput_ab=AB
	bold=md
	reset=me
fi
testGetColorReturn1onBadNumberOfArgument() {
	getColor plop 2>/dev/null ; r=$?
	assertEquals "getColor should return 1" "1" "$r"
}
testGetColorReturnACode() {
	unset a
	allcolors=$(getColor list| grep '#' | cut -d ' ' -f 2)
	local r=$(tput sgr0)
	for c in $allcolors
	do
		getColor a $c
		echo -n "$code$a$c$r "
		assertNotEquals "GetColor $c returned an empty string" "" "$a"
	done
	echo $r
}
testGetColorReturnAugmentedVar() {
	a=a
	getColor a+ red
	b=$"$(tput $tput_af 1)"
	assertEquals "GetColor failed to return previous variable" "a$b" "$a"
}
testGetColorReturnClearedVar() {
	a=a
	getColor a red
	b=$"$(tput $tput_af 1)"
	assertEquals "GetColor failed to return clean variable" "$b" "$a"
}
testGetColorReturnAugmentedVarDoubleColored() {
	a=a
	getColor a+ red reset
	b=$"$(tput $tput_af 1)"$(tput $reset)
	assertEquals "GetColor failed to return previous variable double colored" "a$b" "$a"
}
testGetColorReturnCleanVarDoubleColored() {
	a=a
	getColor a red reset
	b=$"$(tput $tput_af 1)"$(tput $reset)
	assertEquals "GetColor failed to return a clean variable when double colored " "$b" "$a"
}
testGetColorWorksEvenIfItsC() {
	getColor c red
	b=$"$(tput $tput_af 1)"
	assertEquals "Bad code returned" "$b" "$c"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
