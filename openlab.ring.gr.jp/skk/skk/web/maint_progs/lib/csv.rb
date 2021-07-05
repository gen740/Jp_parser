# Copyright (C) 2002 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
#
# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: csv.rb,v 1.2 2002/11/01 22:24:09 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2002/11/01 22:24:09 $

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
# アスキー刊の「オブジェクト指向スクリプト言語ruby」の 121 頁から拝借した
# csv_split 関数については、その著書の一人であるまつもとゆきひろさんに、
# パブリックドメイン扱いで良いとの許可を得た(2002/07/10)。

def csv_split(source, delimiter = ',')
  csv = []
  data = ""
  source.split(delimiter).each do |d|
    if data.empty?
      data = d
    else
      data += delimiter + d
    end
    if /^"/ =~ data
      if /[^"]"$/ =~ data or '""' == data
	csv << data.sub(/^"(.*)"$/, '\1').gsub(/""/, '"')
	data = ''
      end
    else
      csv << d
      data = ''
    end
  end
  raise "cannot decode CSV\n" unless data.empty?
  csv
end

def csv_quote(string)
  if (/,/ =~ string)
    string = '"' + string + '"'
  end
  string
end

def csv_unquote(string)
  string.sub(/^\"(.+)\"$/, '\1')
end

# end of csv.rb
