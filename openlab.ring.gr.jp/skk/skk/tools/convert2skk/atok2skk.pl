#!/usr/local/bin/jperl -Pw

# ATOK7/ATOK8/���� V3/DFJ�̃��[�U����(�e�L�X�g)��
# SKK�̎����ɕϊ�����
# written by nmaeda (Aug/1994)

$backup="";
$line="";

while(<>)	{
	chop;

	if(/[!-�]/)	{	# half-width kana to full-width
		s/\([�-�]\)�[/\1�/g;
		tr/����������������������������������������Ӭԭծ������ܦ���/�@�A�B�C�D�E�F�G�H�I�J�L�N�P�R�T�V�X�Z�\�^�`�b�c�e�g�i�j�k�l�m�n�q�t�w�z�}�~�����������������������������������J�K/;
		tr/�����/�B�A�u�v�[/;

		s/�J�J/�K/g; s/�L�J/�M/g; s/�N�J/�O/g; s/�P�J/�Q/g; s/�R�J/�S/g;
		s/�T�J/�U/g; s/�V�J/�W/g; s/�X�J/�Y/g; s/�Z�J/�[/g; s/�\�J/�]/g;
		s/�^�J/�_/g; s/�`�J/�a/g; s/�c�J/�d/g; s/�e�J/�f/g; s/�g�J/�h/g;
		s/�n�J/�o/g; s/�q�J/�r/g; s/�t�J/�u/g; s/�w�J/�x/g; s/�z�J/�{/g;
		s/�n�K/�p/g; s/�q�K/�s/g; s/�t�K/�v/g; s/�w�K/�y/g; s/�z�K/�|/g;
		s/�E�J/��/g;

	}

	@array=split(/,/);
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


