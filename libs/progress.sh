#!/usr/bin/env bash
function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string> [ <int> ]
	local COLUMNS;COLUMNS="$(tput cols)"
	LANG=C  		        # avoid ./, mistake
	local progress;progress="$1" ;[[ $progress =~ ^[0-9]+$ ]] || return 1; [ "$progress" -gt 100 ] && return 2
	local suf;suf="$2" 
	local NSLICES;NSLICES="${3:-2}";[[ $NSLICES =~ ^[0-9]+$ ]] || return 1 
	# Perl is 3x faster, and much more easier to implement...
	# -CAS make perl assume ARGV and code are utf8
	perl -CAS -MEncode - "$progress" "$suf" "$NSLICES" "$COLUMNS" << 'EOP'
	use utf8;
	use Encode qw( encode_utf8 );
	#my $chars='░▒▓█';
	my $chars='▏▎▍▌▋▊▉█';
	my $nchars=length($chars);
	my $half='/';
	(my $p, my $s, my $nslices, my $cols)=@ARGV;
	my $sparse=7+length(encode_utf8($s));
	my $scale=($cols-$sparse)/100;
	# convert progress into char position
	$p_scaled=($p*$scale);
	# Build the bar: fill with x plain char
	my $bar=substr($chars,$nchars-1,1)x(int($p_scaled));
	my $narrow=$nchars*($p_scaled-int($p_scaled));
	my $arrow=$narrow==0?'':substr($chars,$narrow,1);
	$bar.=$arrow;
	$bar.=' 'x(((100-$p)*$scale));
	my $slice_length=length($bar)/$nslices;
	# Put the | on the bar
	#map {substr($bar,$slice_length*$_,1,'|')} (1+int($p_scaled/$slice_length)..($nslices-1));	# But not on filled part
	map {substr($bar,$slice_length*$_,1,'|')} (1..($nslices-1));
	# Put something in the half
	substr($bar,length($bar)/2,1,$half);
	# Print
	printf "\r%-4s [%s]%.".(length($s))."s","${p}%",$bar,$s;
EOP
}
