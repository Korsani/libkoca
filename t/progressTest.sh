#!/usr/bin/env bash
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testprogress()  {
	COLS=$(tput cols)
	s=$(koca_progress '0' 'a');[[ $s =~ ^.0%\ \ \ \[_.*\]a ]];echo $a; assertTrue 0 $?
	s=$(koca_progress '50' 'a');[[ $s =~ ^.50% ]];assertTrue 50 $?
	s=$(koca_progress '100' 'a');[[ $s =~ ^.100%\ \[.*█\]a ]];assertTrue 100 $?
	s=$(koca_progress '101' 'a');assertFalse "More than 100%" $?
	s=$(koca_progress '-1' 'a');assertFalse "Less than 0" $?
	s=$(koca_progress 'a' 'a');assertFalse "Not a number" $?
	suf='something'
	p=$(perl -e 'printf "%i",rand(100)')		# Some values with some COLS may fail...
	# s: scale factor to which p should be multiplied to have its visual representation according to the terminal width. This is the length, in byte, of the visual representation of 1%
	# fill: how many char p will take, rounded
	# Then, add 7 mandatory chars 'xxx% []', 3x the space take by filling chars (which are unicodes), and the space taken by the 1-byte chars of the empty space
	# This calculation should give me the length of the string koca_progress will print
	lf=$(echo "define trunc(x) { auto s; s=scale; scale=0; x=x/1; scale=s; return x };scale=2;s=($COLS-(7+${#suf}))/100;fill=($p*s);if((fill-trunc(fill))>0) {trunc(fill)+1} else {trunc(fill)}"|bc)
	#echo $lf
	l=$(echo "1+($COLS-$lf)+3*$lf"|bc)
	l=$(printf '%.0f' $l)
	# (that said... when bc will implent int() or round()??
	s=$(koca_progress $p "$suf" 2); assertEquals "Progress does not take the full length for $p%." "$l" "${#s}"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
