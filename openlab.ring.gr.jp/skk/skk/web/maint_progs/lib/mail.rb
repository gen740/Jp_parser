# Copyright (C) 2002, 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: mail.rb,v 1.6 2004/02/06 22:10:58 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2004/02/06 22:10:58 $

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
require 'net/smtp'
require 'kconv'

class Mail

  def send(subject, from, sender, to, mesg,
	   attach0_filename, attach0, attach1_filename, attach1)
    date = Time.now.strftime("%a, %d %b %Y %H:%M:%S +0900")
    message_id = srand(Time.now.strftime("%H%M%S").to_i) &&
      Time.now.strftime("%Y%m%d%H%M%S") + rand(Time.now.strftime("%H%M%S").to_i).to_s + '.' + from
    boundary='Multipart_' + Time.now.strftime("%a_%b_%d_%H:%M:%S_%Y-1")
    mesg = Kconv.tojis(mesg)

    head = <<HEAD
Subject: #{subject}
To: #{to}
From: #{from}
Date: #{date}
Message-ID: <#{message_id}>
X-ML-Name: SKK
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="#{boundary}"
HEAD

    body  = <<-BODY
--#{boundary}
Content-Type: text/plain; charset=ISO-2022-JP

#{mesg}
--#{boundary}
Content-Type: text/plain
Content-Disposition: attachment; filename="#{attach0_filename}"
Content-Transfer-Encoding: 7bit

#{attach0}

--#{boundary}
Content-Type: text/plain
Content-Disposition: attachment; filename="#{attach1_filename}"
Content-Transfer-Encoding: 7bit

#{attach1}
--#{boundary}--
BODY

    ENV['HOSTNAME'] = `/bin/hostname`.chomp

    mail = Net::SMTPSession.new(address = 'localhost', port = 25)
    mail.start()
    mail.sendmail(head + "\n" + body, sender, to)
    begin
      mail.finish
    rescue
      #/usr/local/lib/ruby/1.8/net/smtp.rb:457:in `finish': closing already closed SMTP session (IOError)
      #from /home/minakaji/ruby/mail.rb:76:in `send'
    end
  end

  def send_without_attachment(subject, from, sender, to, mesg)
    date = Time.now.strftime("%a, %d %b %Y %H:%M:%S +0900")
    message_id = srand(Time.now.strftime("%H%M%S").to_i) &&
      Time.now.strftime("%Y%m%d%H%M%S") + rand(Time.now.strftime("%H%M%S").to_i).to_s + '.' + from
    boundary='Multipart_' + Time.now.strftime("%a_%b_%d_%H:%M:%S_%Y-1")
    mesg = Kconv.tojis(mesg)
    head = <<HEAD
Subject: #{subject}
To: #{to}
From: #{from}
Date: #{date}
Message-ID: <#{message_id}>
Content-Type: text/plain; charset=ISO-2022-JP
Mime-Version: 1.0
HEAD

body  = <<-BODY
#{mesg}
BODY

    ENV['HOSTNAME'] = `/bin/hostname`.chomp

    mail = Net::SMTPSession.new(address = 'localhost', port = 25)
    mail.start()
    mail.sendmail(head + "\n" + body, sender, to)
    #mail.finish
  end
end
# end of mail.rb
