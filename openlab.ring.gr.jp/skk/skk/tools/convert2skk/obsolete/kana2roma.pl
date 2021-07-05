#
#	ʿ��̾ʸ�������޻�ʸ������Ѵ����롣
#
#	����ˡ: $romastr = &kana2roma($kanastr)
#
package kana2roma;

$cnv4{"����"} = "kyi";
$cnv4{"����"} = "kye";
$cnv4{"����"} = "kya";
$cnv4{"����"} = "kyu";
$cnv4{"����"} = "kyo";
$cnv4{"����"} = "gyi";
$cnv4{"����"} = "gye";
$cnv4{"����"} = "gya";
$cnv4{"����"} = "gyu";
$cnv4{"����"} = "gyo";
$cnv4{"����"} = "syi";
$cnv4{"����"} = "she";
$cnv4{"����"} = "sha";
$cnv4{"����"} = "shu";
$cnv4{"����"} = "sho";
$cnv4{"����"} = "zyi";
$cnv4{"����"} = "je";
$cnv4{"����"} = "ja";
$cnv4{"����"} = "ju";
$cnv4{"����"} = "jo";
$cnv4{"����"} = "tyi";
$cnv4{"����"} = "che";
$cnv4{"����"} = "cha";
$cnv4{"����"} = "chu";
$cnv4{"����"} = "cho";
$cnv4{"�¤�"} = "dyi";
$cnv4{"�¤�"} = "dye";
$cnv4{"�¤�"} = "dya";
$cnv4{"�¤�"} = "dyu";
$cnv4{"�¤�"} = "dyo";
$cnv4{"�ˤ�"} = "nyi";
$cnv4{"�ˤ�"} = "nye";
$cnv4{"�ˤ�"} = "nya";
$cnv4{"�ˤ�"} = "nyu";
$cnv4{"�ˤ�"} = "nyo";
$cnv4{"�Ҥ�"} = "hyi";
$cnv4{"�Ҥ�"} = "hye";
$cnv4{"�Ҥ�"} = "hya";
$cnv4{"�Ҥ�"} = "hyu";
$cnv4{"�Ҥ�"} = "hyo";
$cnv4{"�Ӥ�"} = "byi";
$cnv4{"�Ӥ�"} = "bye";
$cnv4{"�Ӥ�"} = "bya";
$cnv4{"�Ӥ�"} = "byu";
$cnv4{"�Ӥ�"} = "byo";
$cnv4{"�Ԥ�"} = "pyi";
$cnv4{"�Ԥ�"} = "pye";
$cnv4{"�Ԥ�"} = "pya";
$cnv4{"�Ԥ�"} = "pyu";
$cnv4{"�Ԥ�"} = "pyo";
$cnv4{"�դ�"} = "fa";
$cnv4{"�դ�"} = "fi";
$cnv4{"�դ�"} = "fe";
$cnv4{"�դ�"} = "fo";
$cnv4{"�ߤ�"} = "myi";
$cnv4{"�ߤ�"} = "mye";
$cnv4{"�ߤ�"} = "mya";
$cnv4{"�ߤ�"} = "myu";
$cnv4{"�ߤ�"} = "myo";
$cnv4{"�ꤣ"} = "ryi";
$cnv4{"�ꤧ"} = "rye";
$cnv4{"���"} = "rya";
$cnv4{"���"} = "ryu";
$cnv4{"���"} = "ryo";

$cnv2{"��"} = "-";
$cnv2{"��"} = "xa";
$cnv2{"��"} = "a";
$cnv2{"��"} = "xi";
$cnv2{"��"} = "i";
$cnv2{"��"} = "xu";
$cnv2{"��"} = "u";
$cnv2{"��"} = "xe";
$cnv2{"��"} = "e";
$cnv2{"��"} = "xo";
$cnv2{"��"} = "o";
$cnv2{"��"} = "ka";
$cnv2{"��"} = "ga";
$cnv2{"��"} = "ki";
$cnv2{"��"} = "gi";
$cnv2{"��"} = "ku";
$cnv2{"��"} = "gu";
$cnv2{"��"} = "ke";
$cnv2{"��"} = "ge";
$cnv2{"��"} = "ko";
$cnv2{"��"} = "go";
$cnv2{"��"} = "sa";
$cnv2{"��"} = "za";
$cnv2{"��"} = "shi";
$cnv2{"��"} = "ji";
$cnv2{"��"} = "su";
$cnv2{"��"} = "zu";
$cnv2{"��"} = "se";
$cnv2{"��"} = "ze";
$cnv2{"��"} = "so";
$cnv2{"��"} = "zo";
$cnv2{"��"} = "ta";
$cnv2{"��"} = "da";
$cnv2{"��"} = "chi";
$cnv2{"��"} = "di";
$cnv2{"��"} = "tsu";
$cnv2{"��"} = "du";
$cnv2{"��"} = "te";
$cnv2{"��"} = "de";
$cnv2{"��"} = "to";
$cnv2{"��"} = "do";
$cnv2{"��"} = "na";
$cnv2{"��"} = "ni";
$cnv2{"��"} = "nu";
$cnv2{"��"} = "ne";
$cnv2{"��"} = "no";
$cnv2{"��"} = "ha";
$cnv2{"��"} = "ba";
$cnv2{"��"} = "pa";
$cnv2{"��"} = "hi";
$cnv2{"��"} = "bi";
$cnv2{"��"} = "pi";
$cnv2{"��"} = "fu";
$cnv2{"��"} = "bu";
$cnv2{"��"} = "pu";
$cnv2{"��"} = "he";
$cnv2{"��"} = "be";
$cnv2{"��"} = "pe";
$cnv2{"��"} = "ho";
$cnv2{"��"} = "bo";
$cnv2{"��"} = "po";
$cnv2{"��"} = "ma";
$cnv2{"��"} = "mi";
$cnv2{"��"} = "mu";
$cnv2{"��"} = "me";
$cnv2{"��"} = "mo";
$cnv2{"��"} = "xya";
$cnv2{"��"} = "ya";
$cnv2{"��"} = "xyu";
$cnv2{"��"} = "yu";
$cnv2{"��"} = "xyo";
$cnv2{"��"} = "yo";
$cnv2{"��"} = "ra";
$cnv2{"��"} = "ri";
$cnv2{"��"} = "ru";
$cnv2{"��"} = "re";
$cnv2{"��"} = "ro";
$cnv2{"��"} = "wa";
$cnv2{"��"} = "wi";
$cnv2{"��"} = "we";
$cnv2{"��"} = "wo";
$cnv2{"��"} = "n";

sub main'kana2roma {
	local($_) = @_;
	local($p, $s) = (0, "");
	while($p < length($_)){
		if($cnv4{substr($_,$p,4)}){
			if($tf){
				$s .= substr($cnv4{substr($_,$p,4)},0,1);
				$tf = 0;
			}
			$s .= $cnv4{substr($_,$p,4)};
			$p += 4;
		}
		elsif($cnv2{substr($_,$p,2)}){
			if($tf){
				$s .= substr($cnv2{substr($_,$p,2)},0,1);
				$tf = 0;
			}
			$s .= $cnv2{substr($_,$p,2)};
			$p += 2;
		}
		elsif(substr($_,$p,2) eq "��"){
			$tf = 1;
			$p += 2;
		}
		elsif(ord(substr($_,$p)) >= 0x80){
			$s .= substr($_,$p,2);
			$p += 2;
		}
		else {
			$s .= substr($_,$p,1);
			$p += 1;
		}
	}
	return $s;
}

1;
