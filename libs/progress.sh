function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string> [ <int> ]
	local COLUMNS=$(tput cols)
	LANG=C  		        # avoid ./, mistake
	local progress="$1" ;[[ $progress =~ ^[0-9]+$ ]] || return 1; [ $progress -gt 100 ] && return 2
	local suf="$2" 
	local NSLICES=${3:-2};[[ $NSLICES =~ ^[0-9]+$ ]] || return 1 
	# Perl is 3x faster, and much more easier to implement...
	perl - $progress $suf $NSLICES $COLUMNS << 'EOP'
	my $p=shift;
	my $s=shift;
	my $nslices=shift;
	my $cols=shift;
	my $sparse=7+length($s);
	my $scale=($cols-$sparse)/100;
	# Build the bar
	my $bar='#'x($p*$scale);
	$bar.='_'x((100-$p)*$scale);
	my $slice_length=length($bar)/$nslices;
	# Put the | on the bar
	map {substr($bar,$slice_length*$_,1,'|')} (1..($nslices-1));
	# Print
	printf "\r%-4s [%s]%-".(length($s)+1)."s","${p}%",$bar,$s;
EOP
}
