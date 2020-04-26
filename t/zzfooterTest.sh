#!/usr/bin/env bash
# $Id: zzfooter.sh 1128 2012-08-31 15:44:45Z gab $
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh &>/dev/null
testVersion() {
	v=$(_show_version| grep 'version:'| cut -d ':' -f 2)
	assertEquals "v" "%VERSION%" "$v"
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
