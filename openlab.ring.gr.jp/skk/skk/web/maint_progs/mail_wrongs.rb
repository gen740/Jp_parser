#!/usr/local/bin/ruby -Kj
#
# Copyright (C) 2002, 2003 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
#
# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: mail_wrongs.rb,v 1.6 2003/07/26 08:51:19 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2003/07/26 08:51:19 $

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

# Commentary:

#require 'kconv'
require 'nkf'
require 'csv'
require 'changelog'
require 'mail'
require 'logdic'

DBMFILE = '/circus/openlab/skk/skk/dic/SKK-JISYO.L'
# Remove from SKK-JISYO.L
logdic = Logdic.new
dic = logdic.make(true)
changelog = ChangeLog.new
log = changelog.make('SKK-JISYO.L', DBMFILE, dic, false, true)
#log = NKF.nkf('-f1000', log)
skk_jisyo = ''
dic.each{|key,array|
  array.each{|val|
    temp = key + " /" + val + "/\n"
    skk_jisyo << NKF.nkf('-jf310', temp)
  }
}
#skk_jisyo = Kconv.tojis(skk_jisyo)
subject = 'Request for comment on wrong entries'
from = 'skk@ring.gr.jp'
sender = 'minakaji@ring.gr.jp'
to = 'skk@ring.gr.jp'
#to = 'minakaji@osaka.email.ne.jp'
mesg = <<EOF
  ����� skk@ring.gr.jp �˽����ư���դ�����å������Ǥ���

  http://openlab.ring.gr.jp/skk/registdic.cgi �˰��̤���������Ͽ���줿�����
��Τ��������Τ�ΤˤĤ��Ƥϡ�����Ͽ�Ǥ���ȼ�ĥ����Ƥ��ޤ���

�Ĥ��ޤ��Ƥϡ�SKK Openlab ML �ˤ����ä������ˡ�����饨��ȥ�ν��������ݤˤ�
��������Ƥ���Ƥ��������ޤ��褦�ꥯ�����Ȥ������ޤ���

http://openlab.ring.gr.jp/skk/registdic.cgi �ˡ��������פȤ�����Ͽ���줿���Ƥϡ�
���ͤΤ��ᡢannotation ������ɽ�����Ƥ���ޤ���

�ʤ���MUA �Ǥθ��פ����θ���ơ������� SKK-JISYO.wrong.tmp �� 7bit (JIS ����
��) ��ź�դ���Ƥ��ޤ�����SKK-JISYO.wrong.annotated �� EUC �����ɤǤ��Τǡ�
����ղ�������

�ʾ塢���������ꤤ�������ޤ���
EOF
#mesg = Kconv.tojis(mesg)
mesg = NKF.nkf('-j', mesg)
mail = Mail.new
mail.send(subject, from, sender, to, mesg,
	  "ChangeLog", log, "SKK-JISYO.wrong.annotated.tmp", skk_jisyo)

# end of mail_wrongs.rb
