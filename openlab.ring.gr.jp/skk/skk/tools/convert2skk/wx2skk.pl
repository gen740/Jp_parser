#!/usr/local/bin/jperl -Pw

# WX2+�̃��[�U����(�e�L�X�g)��
# SKK�̎����ɕϊ�����
# written by nmaeda  (Aug/1994)

$backup="";
$line="";

while(<>)	{
	@array=split(/ |\t|:/);
	$array[0]=~tr/�@-��/��-��/;
	$array[1]=~s/"//g;

	if($backup!~/^$array[0]$/)	{	# New entry
		if($line!~/^$/)	{
			printf("%s\n", $line);
		}
		$line=sprintf("%s /%s/", $array[0], $array[1]);
	} else	{				# continue
		$line=$line.$array[1]."/";
	}

	$backup=$array[0];
}
printf("%s\n", $line);
