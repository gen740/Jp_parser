$B!|(B SKK$B<-=q%f%F%#%j%F%#(B
$B!1!1!1!1!1!1!1!1!1!1!1(B
skktools$B$O(BSKK$B<-=q$r%^!<%8$7$?$j(Bpubdic$B<-=q$r(BSKK$B<-=q$KJQ49$7$?$j(B
$B$9$k$?$a$N%D!<%k72$G$9!#(BSKK$B<-=q$OFI$_$KBP1~$9$kJ#?t$N4A;z$,(B'/'
$B$G6h@Z$i$l$?9=B$$r$7$F$$$^$9$,!"$3$N%D!<%k$G$OFI$_$H4A;z$,#1BP(B
$B#1$KBP1~$7$?7A<0!J$3$l$r%j%9%H7A<0$H8F$V$3$H$K$7$^$9!K$N%U%!%$(B
$B%k$rCf4V7A<0$H$7$F<h$j07$$$^$9!#(B

 $B!{(B skk2list	SKK$B<-=q$r%j%9%H7A<0$KJQ49$7$^$9!#(B
 $B!{(B pubdic2list	pubdic$B<-=q$NL>;l%(%s%H%j$r%j%9%H7A<0$KJQ49$7$^$9!#(B
 $B!{(B list2skk	$B%j%9%H7A<0$r(BSKK$B<-=q$KJQ49$7$^$9!#(B
 $B!{(B adddummy	SKK$B<-=q%=!<%H$N$?$a$K%@%_!<J8;z$r2C$($^$9!#(B
 $B!{(B removedummy	$B2C$($?%@%_!<<-=q$r<h$j=|$-$^$9!#(B

$BNc$($P4{B8$N(BSKK$B<-=q$H(Bpubdic$B<-=q$r%^!<%8$7$F?7$7$$(BSKK$B<-=q$r:n@.(B
$B$9$k$K$O<!$N$h$&$K9T$J$$$^$9!#(B

  % (skk2list skk-jisyo ; pubdic2list kihon.u) \ ; $B%j%9%H7A<0$rO"7k(B
	| adddummy \				 ; $B%@%_!<J8;zDI2C(B
	| sort -u \				 ; $B%=!<%H(B
	| removedummy \				 ; $B%@%_!<J8;z:o=|(B
	| list2skk \				 ; SKK$B<-=q$KJQ49(B
	> skk-jisyo.new

$B$3$l$i$N%D!<%k$G$O(BEUC$B$N<-=q$N$_<h$j07$$2DG=$G$9!#$=$l0J30$N(B
$B<-=q$r;H$&$H$-$O8e=R$N(Bjis2ujis$B$J$I$N%3%^%s%I$r2C$($F2<$5$$!#(B

$B!|(B $B:9J,$N7W;;(B
$B!1!1!1!1!1!1!1(B
"sub"$B$O$U$?$D$N%U%!%$%k$N:9J,$r=PNO$9$k%3%^%s%I$G$9!#(Bskk$B<-=q$K?7$?$K(B
$B2C$($i$l$?%(%s%H%j$rCj=P$9$k$K$O!"?75l$N(Bskk$B<-=q$N%j%9%H7A<0$rMQ0U$7!"(B

  % sub $B5l%j%9%H(B $B?7%j%9%H(B

$B$H$7$^$9!#Hf$Y$i$l$k$U$?$D$N%U%!%$%k$O$"$i$+$8$a%=!<%H$5$l$F$$$J$1$l$P(B
$B$J$j$^$;$s!#(B

$B!|(B $B4A;z8!:w%3%^%s%I(B
$B!1!1!1!1!1!1!1!1!1!1(B
"skkconv"$B$O(Bskk$B%5!<%P$r;HMQ$7$F%3%^%s%I%i%$%s$G$+$J4A;zJQ49$9$k$?$a$N(B
$B%3%^%s%I$G$9!#Nc$($P!V$+$s$8!W$H$$$&FI$_$r$b$D4A;z$r0J2<$N$h$&$K(B
$B8!:w$G$-$^$9!#(B

  % skkconv kanji
  $B4A;z(B
  $B44;v(B
  $B46$8(B
  ......
  %

$B!|(B $B%f%F%#%j%F%#(B
$B!1!1!1!1!1!1!1!1(B
$B0J2<$N(Bperl$B%i%$%V%i%j$H%3%^%s%I$O$*$^$1$G$9!#(B

 $B!{(B codeconv.pl		JIS,EUC,SJIS$BAj8_JQ49%i%$%V%i%j(B
 $B!{(B roma2kana.pl	$B%m!<%^;z"*J?2>L>JQ49%i%$%V%i%j(B
 $B!{(B kana2roma.pl	$BJ?2>L>"*%m!<%^;zJQ49%i%$%V%i%j(B
 $B!{(B jis2sjis		JIS$B"*(BSJIS$BJQ49%3%^%s%I(B
    sjis2jis		SJIS$B"*(BJIS$BJQ49%3%^%s%I(B
    jis2ujis		JIS$B"*(BEUC$BJQ49%3%^%s%I(B
    ujis2jis		EUC$B"*(BJIS$BJQ49%3%^%s%I(B
    roma2kana		$B%m!<%^;z"*$+$J(B(EUC)$BJQ49%3%^%s%I(B 
    kana2roma		$B$+$J(B(EUC)$B"*%m!<%^;zJQ49%3%^%s%I(B 

Perl$B%i%$%V%i%j(B(*.pl)$B$O(Bperl$B$N%i%$%V%i%j%G%#%l%/%H%j$K3JG<$7$F(B
$B2<$5$$!#(B

$B!|(B $B%$%s%9%H!<%kJ}K!(B
$B!1!1!1!1!1!1!1!1!1(B
perl$B$N@dBP%Q%9$r(BMakefile$BFb$G;XDj$7$F(Bmake$B$7$F$/$@$5$$!#(B


$BA}0f=SG7(B
$B%+!<%M%.!<%a%m%sBg3X5!3#K]Lu%;%s%?(B
masui@cs.cmu.edu

