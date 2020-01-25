function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string> [ <int> ]
	local COLUMNS=$(tput cols)
	LANG=C  		        # avoid ./, mistake
	local progress="$1" ;[[ $progress =~ ^[0-9]+$ ]] || return 1; [ $progress -gt 100 ] && return 2
	local suf="$2" 
	local NSLICES=${3:-2};[[ $NSLICES =~ ^[0-9]+$ ]] || return 1 
	# Perl is 3x faster, and much more easier to implement...
	perl -CS - "$progress" "$suf" "$NSLICES" "$COLUMNS" << 'EOP'
	use utf8;
	#my $chars='░▒▓█';
	my $chars='▏▎▍▌▋▊▉█';
	my $nchars=length($chars);
	my $p=shift;
	my $s=shift;
	my $nslices=shift;
	my $cols=shift;
	my $sparse=7+length($s);
	my $scale=$nchars*($cols-$sparse)/100;
	# Build the bar
	$p_scaled=($p*$scale)/$nchars;
	my $bar=substr($chars,$nchars-1,1)x(int($p_scaled)-1);
	my $arrow=substr($chars,$nchars*($p_scaled-int($p_scaled)-1),1),"\n";
	$bar.=$arrow;
	$bar.=' 'x(1+(100-$p)*$scale/$nchars);
	my $slice_length=length($bar)/$nslices;
	# Put the | on the bar
	# But not on filled part
	map {substr($bar,$slice_length*$_,1,'|')} (1+int($p_scaled/$slice_length)..($nslices-1));
	# Print
	printf "\r%-4s[%s]%-".length($s)."s","${p}%",$bar,$s;
EOP
}
