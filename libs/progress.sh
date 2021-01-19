function koca_progress {    # Display a non blocking not piped progress. Usage: $0 <progress%> <string> [ <int> ]
	LANG=C  		        # avoid ./, mistake
	local progress="$1" ;[[ $progress =~ ^[0-9]+$ ]] || return 1; [ $progress -gt 100 ] && return 2
	local suf="$2" 
	local NSLICES=${3:-2};[[ $NSLICES =~ ^[0-9]+$ ]] || return 1 
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
	my $mb_length=length(encode_utf8($s))-length($s);
	# Space taken by everything but the bar
	my $text_length=7+length($s)+$mb_length/2;	#Roughly...
	my $bar_length=$cols-$text_length;
	$bar_length=$bar_length>3?$bar_length:3;
	my $scale=($bar_length)/100;
	# convert progress into char position
	$p_scaled=($p*$scale);
	# Build the bar: fill with x plain char
	my $bar=substr($chars,$nchars-1,1)x(int($p_scaled));
	my $narrow=$nchars*($p_scaled-int($p_scaled));
	my $arrow=$narrow==0?'':substr($chars,$narrow,1);
	$bar.=$arrow;
	$bar.=' 'x(((100-$p)*$scale));
	# Adding clr_eol sequence (in case of)
	#$bar.="\e[K";
	my $slice_length=length($bar)/$nslices;
	# Put the | on the bar
	#map {substr($bar,$slice_length*$_,1,'|')} (1+int($p_scaled/$slice_length)..($nslices-1));
	map {substr($bar,$slice_length*$_,1,'|')} (1..($nslices-1));
    substr($bar,length($bar)/2,1,$half);
	# Print
	my $suf_length=$cols-(4+2+length($bar)+1);
	#printf "\r%-4s [%s]\e[K%-.".(length($s))."s","${p}%",$bar,$s;
	printf "\r%-4s [%s]\e[K%-.".($suf_length)."s","${p}%",$bar,$s;
EOP
}
