#!/usr/local/bin/jperl -Pw

# SKK�̎�������A
#   ���o�����A���t�@�x�b�g�ŁA�\�L���J�^�J�i�A
# �ł���G���g����T���A
#   ���o�����J�^�J�i�ŁA�\�L���J�^�J�i�A
# �ɕϊ����A�\������B
#
# written by nmaeda@SANSEIDO Printing Co.,Ltd. (Aug/1994)

open(handle, "| sort | uniq") || die "can't open pipe\n";

while(<>)	{
	chop;

	# �\�L���J�^�J�i(�����Ƃ̕�����ł͂Ȃ�)
	if(/^([a-zA-Z]+) .*\/([�@-��][�@-���[�E]+)\//)	{
		$alpha_read=$1;

		$count=0;
		while($_=~/\/([�@-��][�@-���[�E]+)\//)	{
			$face=$1;
			$kana_read=$face;
			$kana_read=~s/�E//g;	# �ǂ݂���'�E'���폜
			$kana_read=~tr/�@-��/��-��/;	# �ǂ݂��Ђ炪�Ȃ�
			if($kana_read=~/[�@-��]/)	{
				$_=$';
				next;	# ��-�����ӂ��ރG���g���͍폜
			}
			printf(handle "%s /%s/\n", $kana_read, $face);
			$_=$';
			$count++;
		}
		printf(STDERR "%d %-50s\r", $count, $alpha_read);
	}	
}

close(handle);
