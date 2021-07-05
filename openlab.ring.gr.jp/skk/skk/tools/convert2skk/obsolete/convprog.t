#!PERLPATH
#
#	sjis2jis, jis2sjis, ujis2jis, jis2ujis --- $@4A;z%3!<%IJQ49(J
#	roma2kana, kana2roma
#
#		1990	12/17	$@A}0f=SG7(J
#
eval "exec PERLPATH -S $0 $*"
	if $Shell_cannot_understand;

($program) = ($0 =~ m#([^/]+)$#);

require "codeconv.pl" if $program =~ /jis/;
require "roma2kana.pl" if $program =~ /roma2kana/;
require "kana2roma.pl" if $program =~ /kana2roma/;

while(<>){
	chop;
	print do $program($_), "\n";
}
