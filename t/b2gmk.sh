#!/usr/bin/env bash
source $(cd $(dirname "$0") ; pwd)/bootstrap.sh
testB2K() {
	assertEquals 1.0k $(koca_b2gmk 1024)
	assertEquals 1.9k $(koca_b2gmk $(echo 1024*2-1|bc))
	assertEquals 500.0k $(koca_b2gmk $(echo 500*1024|bc))
	assertEquals 1.0M $(koca_b2gmk $(echo 1024^2|bc))
	assertEquals 1.0M $(koca_b2gmk $(echo 1024^2+1|bc))
	assertEquals 1.5M $(koca_b2gmk $(echo 1024^2+512*1024|bc))
	assertEquals 500.0M $(koca_b2gmk $(echo 500*1024^2|bc))
	assertEquals 1.0G $(koca_b2gmk $(echo 1024^3|bc))
	assertEquals 500.0G $(koca_b2gmk $(echo 500*1024^3|bc))
	assertEquals 1.0T $(koca_b2gmk $(echo 1024^4|bc))
	assertEquals 500.0T $(koca_b2gmk $(echo 500*1024^4|bc))
	assertEquals 1.0P $(koca_b2gmk $(echo 1024^5|bc))
	assertEquals 500.0P $(koca_b2gmk $(echo 500*1024^5|bc))
	assertEquals 1.0P $(koca_b2gmk $(echo 1024^5+1024^3|bc))
	assertEquals 100 $(koca_b2gmk 100)
	assertEquals 300 $(koca_b2gmk 300)
	assertEquals 1.0k $(koca_b2gmk 1025)
	assertEquals 0 $(koca_b2gmk 0)
}
testFalse() {
	assertFalse 'N/A' $(koca_b2gmk 'N/A') 2>/dev/null
}
source $(cd $(dirname "$0") ; pwd)/footer.sh
