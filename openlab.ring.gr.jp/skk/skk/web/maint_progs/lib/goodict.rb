# Copyright (C) 2002, 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: goodict.rb,v 1.12 2003/04/05 13:21:31 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2003/04/05 13:21:31 $

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
require 'socket'
require 'cgi'
require 'kconv'
require 'skkutils'
require 'timeout'

class GooDict

  Okurigana = {
    "a" => ["あ"],
    "b" => ["ば", "ばしい", "ばむ", "び", "ぶ", "べ", "ぼ", "ぼす"],
    "d" => ["だ", "ぢ", "づ", "で", "ど"],
    "e" => ["え", "える"],
    "g" => ["が", "がる", "ぎ", "ぐ", "げ", "ご"],
    "h" => ["は", "ひ", "ふ", "へ", "ほ"],
    "i" => ["い"],
    "j" => ["ざる", "じ", "じる"],
    "k" => ["か", "かう", "かし", "かしい", "かす", "かぶ", "き", "きい", "きる", "く", "け", "ける", "こ", "こえる", "こる"],
    "m" => ["ま", "まる", "まれる", "み", "む", "め", "める", "も", "もしい", "もる"],
    "n" => ["な", "ない", "なう", "なる", "に", "ぬ", "ね", "の", "ん"],
    "o" => ["お"],
    "p" => ["ぱ", "ぴ", "ぷ", "ぺ", "ぽ"],
    "r" => ["ら", "らう", "らえる", "らか", "らぐ", "らす", "らむ", "り", "る", "るい", "れ", "れむ", "れやか", "れる", "ろ", "ろしい"],
    "s" => ["さ", "さい", "さえる", "し", "しい", "しむ", "す", "する", "せ", "そ"],
    "t" => ["た", "たい", "たる", "ち", "っ", "って", "つ", "て", "てる", "と", "とす"],
    "u" => ["う", "うい"],
    "w" => ["わ", "わう", "わす", "わる", "われる", "を"],
    "x" => ["ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ", "ゎ", "ゐ", "ゑ"],
    "y" => ["ゃ", "や", "やか", "やす", "ゅ", "ゆ", "ょ", "よ"],
    "z" => ["ざ", "ざる", "じ", "じる", "ず", "ぜ", "ぞ"],
  }

  def search(key, switch = 'jn', mode = 1)
    # switch = 'jn' ; daijirin/shingo
    # switch = 'ej' ; eiwa
    # switch = 'je' ; waei
    # mode = 0; substring
    # mode = 1; perfect match
    # mode = 3; search body text
    return false if key.nil?
    key = cut_off_prefix_postfix(key)
    v = []
    timeout(20) {
      begin
	sock = TCPSocket.open("dictionary.goo.ne.jp", 80)
	sock.printf("GET http://dictionary.goo.ne.jp/search.php?MT=%s&kind=%s&mode=%d HTTP/1.0\r\n\r\n",
		    CGI::escape(key), switch, mode)
	sock.readlines.each do |line|
	  temp = pickup(key, switch, Kconv.toeuc(line))
	  if !(temp.empty?)
	    v = v + temp
	  end
	end
      ensure
	sock.close if sock
      end
      if !(v.empty?)
	v.each do |candidate|
	  temp = candidate.gsub(/(.)(\1)/, '\1' + "々")
	  if !v.include?(temp)
	    v.push(temp)
	  end
	end
      end
    }
    v
  end

  def pickup(key, switch, line)
    v = Array.new
    if (switch == 'ej')
      if (/^<font color=\"#[a-z0-9]+\"><b>([^<>]+)<\/b><\/font>/ =~ line)
	v.push($1.gsub(/・/, ''))
      end
    elsif (switch == 'jn')
      if (/【(.*)】/ =~ line) ||
	  #<font color="#cc3333"><b>マイル</b> <sub>1</sub> [mile]</font>
	  (/^<font color=\"#[a-z0-9]+\"><b>([^<>]+)<\/b> <sub>[0-9]+<\/sub> \[#{key}\]<\/font>/ =~ line)
	target = $1
	while /([^】]+)】[^【]+【([^】]+)/ =~ target
	  target = $1 + "・" + $2
	end
	target.split("・").each {|word|
	  word.gsub!(/<[^<>]+>|〈|〉|《|》/, '')
	  if /(.+)（(.+)）/ =~ word
	    #【行う（行なう）】
	    v.push($1).push($2)
	  elsif /\((.+)\)/ =~ word
	    # <B>かばやき  【蒲焼(き)】  </B></TD>
	    # <B>くりごと  【繰(り)言】  </B>
	    temp = word
	    while /(.*)\(([^()]+)\)(.*)/ =~ temp
	      # with all characters with parens
	      temp = $1 + $2 + $3
	    end
	    v.push(temp)
	    temp = word
	    while /(.*)\(([^()]+)\)(.*)/ =~ temp
	      # without characters with parens
	      temp = $1 + $3
	    end
	    v.push(temp)
	    # XXX with/without characters with parens
	  else
	    v.push(word)
	  end
	}
      end
    end
    v
  end

  def search_with_okuri_process(key, candidate, switch = 'jn', mode = 1)
    #key := 'そぶr', candidate := '素振'
    return false unless /^([ーぁ-ん]+)([a-z])$/ =~ key
    key = $1 #'そぶ'
    if !(okurigana = Okurigana[$2])
      return false
    else
      okurigana.each do |char|
	if search(key + char, switch, mode).include?(candidate + char)
	  return (key + char) + "," + (candidate + char)
	end
      end
    end
    false
  end

end
# end of goodict.rb
