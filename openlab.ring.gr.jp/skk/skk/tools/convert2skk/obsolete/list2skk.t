#!PERLPATH
$notfirst = 0;
while(<>){
	chop;
	if(/^([^ \t]+)[ \t]+([^ \t]+)/){
		if($w ne $1){
			print "\n" if $notfirst;
			$notfirst = 1;
			$w = $1;
			print "$w /$2/";
		}
		else {
			print "$2/";
		}
	}
}
print "\n";
