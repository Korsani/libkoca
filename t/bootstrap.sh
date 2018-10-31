here=$(cd $(dirname "$0") ; pwd)
bn=$(basename "$0" Test.sh)
if [ -e $here/../libs/$bn.sh ]
then
	source $here/../libs/$bn.sh
else
	echo "Can't include $bn.sh"
	exit 1
fi
