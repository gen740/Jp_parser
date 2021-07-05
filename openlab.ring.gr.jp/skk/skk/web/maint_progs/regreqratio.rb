#!/usr/local/bin/ruby -Kj
#
# Copyright (C) 2003 NAKAJIMA Mikio <minakaji@namazu.org>

# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: regreqratio.rb,v 1.3 2003/07/08 11:01:09 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Created: Mar. 17, 2003
# Last Modified: $Date: 2003/07/08 11:01:09 $

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

require 'cgi-lib'
require 'csv'
require 'nkf'
require 'mail'
require 'dbm'

Dbmfile = '/usr/home/minakaji/log/regreqratio'
Logdir = '/circus/openlab/skk/log'

# str = "20030317"
# Time.mktime(str[0,4].to_i, str[4,2].to_i, str[6,2].to_i)
# Mon Mar 17 00:00:00 JST 2003
#date,remote_addr,remote_host,comment,rate

now = Time.now()
dbm = DBM.open(Dbmfile, 0666)
begin
  Dir.foreach(Logdir) do |file|
    total_rate = 0
    # %A4%A2%A4%A4%A4%CF+%B0%A6%CD%D5.log
    fname = File.basename(file, '.log')
    lastsent = dbm[fname]
    if lastsent
      # restore time object
      lastsent = Time.mktime(lastsent[0,4].to_i, lastsent[4,2].to_i,
			     lastsent[6,2].to_i)
    end
    if !(fname =~ /([^+]+)\+([^+]+)/)
      next
    end
    key = $1
    word = $2
    file = File.expand_path(file, Logdir)
    File.foreach(file) do |line|
      date,remote_addr,remote_host,comment,rate = csv_split(line.chomp)
      total_rate = rate.to_i + total_rate
    end
    if ((total_rate > 20) || (total_rate < -20)) &&
	# hours  minutes  seconds
	#  24   *  60    *  60    = 86400
	# 21 means three weeks
	(!lastsent || (((now - lastsent) / 86400) > 21))
      mail = Mail.new
      subj = 'Notice of an important comment URL'
      from = 'skk@ring.gr.jp'
      sender = 'minakaji@ring.gr.jp'
      to = 'skk@ring.gr.jp'
      #to = 'minakaji@osaka.email.ne.jp'
    mesg = <<-EOF
このメッセージは自動配信されています。

`#{CGI::unescape(key)} /#{CGI::unescape(word)}/' についての、辞書への登録
希望度が #{total_rate} になりました。

コメントのご検討をお願いします。

http://openlab.ring.gr.jp/skk/registcomment.cgi?midasi=#{key}&word=#{word}
EOF
      mesg = NKF.nkf('-j', mesg)
      mail.send_without_attachment(subj, from, sender, to, mesg)
      dbm[fname] = now.strftime("%Y%m%d")
    end
  end
ensure
  dbm.close
end


# end of regreqratio.rb
