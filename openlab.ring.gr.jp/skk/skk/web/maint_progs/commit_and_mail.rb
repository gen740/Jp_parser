#!/usr/local/bin/ruby -Kj
#
# Copyright (C) 2002, 2003, 2004 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>

# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: commit_and_mail.rb,v 1.14 2005/10/23 17:11:51 skk-cvs Exp $
# Keywords: japanese, dictionary, web maintenance
# Created: Oct. 13, 2002
# Last Modified: $Date: 2005/10/23 17:11:51 $

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program, see the file COPYING.  If not, write to the
# Free Software Foundation Inc., 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.

## Commentary:

Cam_Debug = false # true
#require 'kconv'
require 'csv'
require 'mail'
require 'nkf'
require 'changelog'
require 'logdic'

L_Header = <<EOF
;; -*- mode: fundamental; coding: euc-jp -*-
;; Large size dictionary for SKK system
;; Copyright (C) 1988-1995, 1997, 1999-2005
;;
;; Masahiko Sato <masahiko@kuis.kyoto-u.ac.jp>
;; Hironobu Takahashi <takahasi@tiny.or.jp>,
;; Masahiro Doteguchi, Miki Inooka,
;; Yukiyoshi Kameyama <kameyama@kuis.kyoto-u.ac.jp>,
;; Akihiko Sasaki, Dai Ando, Junichi Okukawa,
;; Katsushi Sato and Nobuhiro Yamagishi
;; NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
;; MITA Yuusuke <clefs@mail.goo.ne.jp>
;; SKK Development Team <skk@ring.gr.jp>
;;
;; Maintainer: SKK Development Team <skk@ring.gr.jp>
;; Version: $Id: commit_and_mail.rb,v 1.14 2005/10/23 17:11:51 skk-cvs Exp $
;; Keywords: japanese
;; Last Modified: $Date: 2005/10/23 17:11:51 $
;;
;; This dictionary is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This dictionary is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Daredevil SKK, see the file COPYING.  If not, write to
;; the Free Software Foundation Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;; ACKNOWLEDGEMENT
;;
;; ���μ���ϡ�SKK ����Ԥκ�ƣ��ɧ���������� 1 �Ǻ����Τ�����������
;; �ŵ��̿�����꺴ƣ���漼 (����) �γ�������ã�ȤȤ�� scratch �����
;; �����줿�Τ򤽤ε����Ȥ������θ塢̵���Υ桼������Υ桼���������
;; ����ե�����ˤ���ɲá����ܤˤ�äƺ����������ƥʥ󥹤���Ƥ�����
;; �ܤǺ��絬�ϤΡ�GPL �ˤ�� copy free �μ���Ǥ���
;;
;; ���μ���κ����ˤ�����ĺ�������Ƥ����˴��դ���ȶ��ˡ�������ɤ�
;; �Τ��ʤ��Τ����Ϥ�����Ȥ⤪�Ԥ����Ƥ���ޤ���
;;
;;   http://openlab.ring.gr.jp/skk/registdic.cgi
;;
;; �˥������������ե���������󤢤ʤ��ο��졦����Ͽ��Ŧ�������Ȥ��
;; ���Ʋ�������
;;
;; �ޤ����ºݤ˼�����Խ��򤷤Ƥߤ����Ȥ������ϡ�
;;
;;   http://openlab.ring.gr.jp/skk/cvs-ja.html#account
;;
;; �����ξ塢cvs account ��ȯ�Կ������ߤ򤷤Ʋ�������
;;
;; ������Խ����ˤ� skk/dic/READMEs/committers.txt �򤴻��Ȳ�������
;; �����˵��ܤΤʤ����ࡢ�ޤ������ѹ��ˤĤ��Ƥϡ��������� SKK Openlab
;; ML ���ä��礤�Ƿ����ޤ���
;;
EOF

Jinmei_Header = <<EOF
;; ��̾���� for SKK system
;; Copyright (C) 1993 Wnn Consortium
;; Copyright (C) 2004 Akie Kaidoh <kaidoh@ma.ctk.ne.jp>
;; Copyright (C) 2002-2005 SKK Development Team <skk@ring.gr.jp>
;;
;; Author: OMRON SOFTWARE Co., Ltd. <freewnn@rd.kyoto.omronsoft.co.jp>
;; Maintainer: SKK Development Team <skk@ring.gr.jp>
;; Version: $Id: commit_and_mail.rb,v 1.14 2005/10/23 17:11:51 skk-cvs Exp $
;; Keywords: japanese
;; Last Modified: $Date: 2005/10/23 17:11:51 $
;;
;; This dictionary is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This dictionary is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; �ܼ���ϡ�skk/tools/convert2skk/wnn2skk.awk �����Ѥ��ֿ�̾����
;; (gerodic) 1.00�פ� SKK ����������Ѵ�������Τ�١����˲ý�����
;; ��ΤǤ���
;;
;;   % gawk -f wnn2skk.awk gerodic/g-jinmei.u > temp
;;   % skkdic-expr temp | skkdic-sort > SKK-JISYO.jinmei
;;
;; Wnn ���ʻ�ǡ����������Ȥ� SKK annotation �Ȥ��Ƽ�����˴ޤ�
;; �Ƥ��ޤ���annotation �����פ����� skk/dic/unannotation.awk ����
;; �Ѥ��ƺ�����Ʋ�������
;;
;; (�ɵ�)
;; �����ѤΡֿ�̾Ͽ�פ˺�Ͽ����Ƥ��롢��ʹ�˽и�������̾�� 25,000
;; ������̾��ʬ�򤷤���Ф��� 11,498 candidates �����䤷�ޤ�����
;;
;;   http://www.ctk.ne.jp/~kaidoh/
;;
;; ���Ѥ�������Ʋ����ä����ֿ�̾Ͽ�ױ��ļԤγ�ƻ�����ͤΤ����դ�
;; ���դ��ޤ���
;;
EOF

Tmpdir = '/usr/home/minakaji/tmp/'
Codir = '/usr/home/minakaji/skk/dic/'
Tmp0 = Tmpdir + 'SKK-JISYO.tmp.0'
Tmp1 = Tmpdir + 'SKK-JISYO.tmp.1'
ChangeLog_Tmp = Tmpdir + 'ChangeLog.tmp'
ChangeLog_Orig = Codir + 'ChangeLog'

def make_new_JISYO(dictionary_file, logdic, header = '')
  num = 0
  File.open(dictionary_file, 'a') do |file_handler|
    logdic.each do |con0, con1|
      num = num + con1.length
      file_handler.print con0, " /", con1.join("/"), "/\n"
    end
  end
  command = '/usr/home/minakaji/bin/skkdic-expr2 ' + dictionary_file + ' >' + Tmp0
  if !(ret = system(command)) # filtered by skkdic-expr2
    return false
  end
  File.open(Tmp1, 'w') do |tmp1|
    # add header
    tmp1.print header
    File.open(Tmp0, 'r') do |tmp0|
      tmp1.print tmp0.readlines
    end
  end
  if File.exist?(Tmp0)
    File.unlink(Tmp0)
  end
  if File.exist?(Tmp1)
    File.rename(Tmp1, dictionary_file)
  end
  num
end

def make_new_ChangeLog(changelog)
  File.open(ChangeLog_Orig) do |orig|
    File.open(ChangeLog_Tmp, 'w') do |new|
      new.print changelog, "\n"
      new.print orig.readlines
    end
  end
  if File.exist?(ChangeLog_Tmp)
    File.rename(ChangeLog_Tmp, ChangeLog_Orig)
  end
end

def main(dictionary_file, header)
  basename = File.basename(dictionary_file)
  if basename == 'SKK-JISYO.jinmei'
    logdic = Logdic.new.make_jinmei()
  elsif basename == 'SKK-JISYO.L'
    logdic = Logdic.new.make(false, true, false)
  else
    raise 'Error: Unknown dictionary!'
  end
  if File.exist?(ChangeLog_Orig)
    File.unlink(ChangeLog_Orig)
  end
  if File.exist?(dictionary_file)
    File.unlink(dictionary_file)
  end
  command = "cd /usr/home/minakaji ; cvs checkout skk/dic/#{basename} skk/dic/ChangeLog"
  if !((logdic.size > 0) && system(command))
    return false
  end
  changelog = ChangeLog.new
  changelog_txt = changelog.make(dictionary_file, logdic)
  make_new_ChangeLog(changelog_txt)
  # remake changelog to fold lines...
  changelog_txt = changelog.make(dictionary_file, logdic, true, true)

  num = make_new_JISYO(dictionary_file, logdic, header)
  command = 'cd /usr/home/minakaji ; cvs commit -m "See ChangeLog." skk/dic/ChangeLog ' + "skk/dic/#{basename}"

  if !Cam_Debug
    if !system(command)
      return false
    end
  end
  print command, "\n" if Cam_Debug
  skk_jisyo = ''
  logdic.sort.each do |con0, con1|
    temp = con0 + " /" + con1.join("/") + "/\n"
    skk_jisyo << NKF.nkf('-jf310', temp)
  end
  mail = Mail.new
  subj = "Request for comment on new commitment of #{basename}"
  from = 'skk@ring.gr.jp'
  sender = 'minakaji@ring.gr.jp'
  if Cam_Debug
    to = 'minakaji@osaka.email.ne.jp'
  else
    to = 'skk@ring.gr.jp'
  end
  if basename == 'SKK-JISYO.jinmei'
    mesg = <<-EOF
  http://openlab.ring.gr.jp/skk/registdic.cgi ����Ͽ���줿�����ɲô�˾�����
��Τ�������̾�ط��Ȥ�����Ͽ���줿�� #{num} ��򵡳�Ū���ɲä� commit ��������
������
EOF
  elsif basename == 'SKK-JISYO.L'
    mesg = <<-EOF
  ����� skk@ring.gr.jp �˽����ư���դ�����å������Ǥ���

  http://openlab.ring.gr.jp/skk/registdic.cgi ����Ͽ���줿�����ɲô�˾�����
��Τ�����goo ����˷Ǻܤ���Ƥ���� #{num} ��򵡳�Ū���ɲä� commit ��������
������
EOF
  end
  mesg = mesg + <<-EOF
�������ɲäˤĤ��ơ������ڤ��������ޤ��褦�ꥯ�����Ȥ������ޤ���

Ʊ�����Ф��줬���˼���ˤ��ä����ϡ������θ���ϡ�����Ū�˺Ǹ������ɲä���
�Ƥ��ޤ���¾�θ�Ȥ����٤ʤɤ��θ���ơ�����ν��֤��ѹ����뤳�Ȥ����Ԥ����
����

�ޤ���http://openlab.ring.gr.jp/skk/registdic.cgi �ˡ��������פȤ�����Ͽ����
�����Ƥϡ�����Ū�� annotation �Ȥ����ɲä��Ƥ���ޤ���Ŭ�ڤ��ѹ�����ʤꡢ��
�פǤ���к������ʤꤹ�뤳�Ȥ����Ԥ���ޤ� (�ʤ���L ����ˤ��Ѷ�Ū��
annotation ���դ��뤳�Ȥ��侩����Ƥ��ޤ�)��

�����Ȥ� skk@ring.gr.jp �ޤǤ��󤻤����������ޤ��ϼ��Ȥˤ�ä��Խ� &
commit ���������ޤ��褦���������ꤤ�������ޤ���
EOF
  mesg = NKF.nkf('-j', mesg)
  mail.send(subj, from, sender, to, mesg,
	    "ChangeLog", changelog_txt, "SKK-JISYO.tmp", skk_jisyo)
end

main(Codir + 'SKK-JISYO.L', L_Header)
main(Codir + 'SKK-JISYO.jinmei', Jinmei_Header)
# end of commit_and_mail.rb
