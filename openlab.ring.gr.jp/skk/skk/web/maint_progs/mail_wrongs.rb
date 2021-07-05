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
  これは skk@ring.gr.jp に週一回自動送付されるメッセージです。

  http://openlab.ring.gr.jp/skk/registdic.cgi に一般の方から登録されたエント
リのうち、次のものについては、誤登録であると主張されています。

つきましては、SKK Openlab ML にご参加の方々に、これらエントリの修正の要否につ
き、ご検討していただきますようリクエストいたします。

http://openlab.ring.gr.jp/skk/registdic.cgi に「用例等」として登録された内容は、
参考のため、annotation 形式で表示してあります。

なお、MUA での見易さを考慮して、末尾の SKK-JISYO.wrong.tmp は 7bit (JIS コー
ド) で添付されていますが、SKK-JISYO.wrong.annotated は EUC コードですので、
ご注意下さい。

以上、宜しくお願いいたします。
EOF
#mesg = Kconv.tojis(mesg)
mesg = NKF.nkf('-j', mesg)
mail = Mail.new
mail.send(subject, from, sender, to, mesg,
	  "ChangeLog", log, "SKK-JISYO.wrong.annotated.tmp", skk_jisyo)

# end of mail_wrongs.rb
