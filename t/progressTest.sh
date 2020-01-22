#!/usr/bin/env bash
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testprogress()  {
	s=$(koca_progress '0' 'a');[[ $s =~ ^.0%\ \ \ \[_.*\]a ]];echo $a; assertTrue 0 $?
	s=$(koca_progress '50' 'a');[[ $s =~ ^.50% ]];assertTrue 50 $?
	s=$(koca_progress '100' 'a');[[ $s =~ ^.100%\ \[.*#\]a ]];assertTrue 100 $?
	s=$(koca_progress '101' 'a');assertFalse "More than 100%" $?
	s=$(koca_progress '-1' 'a');assertFalse "Less than 0" $?
	s=$(koca_progress 'a' 'a');assertFalse "Not a number" $?
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
