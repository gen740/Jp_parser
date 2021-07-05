# Copyright (C) 2002, 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: lycosdict.rb,v 1.10 2003/04/05 03:17:42 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Created: Oct. 20, 2002
# Last Modified: $Date: 2003/04/05 03:17:42 $

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

class LycosDict

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

  def initialize
    @url = nil
  end

  def url
    @url
  end

  def search_daijisen(key)
    return false if key.nil?
    key = cut_off_prefix_postfix(key)
    v = Array.new
    begin
      sock = TCPSocket.open("dic.lycos.co.jp", 80)
      sock.sync = true
      @url = "http://dic.lycos.co.jp/djs/list.html?query=#{CGI::escape(Kconv.toeuc(key))}&encoding=euc-japan"
      sock.printf("GET %s HTTP/1.0\r\n\r\n", @url)
      array = sock.readlines
      if (array[0] == "HTTP/1.1 302 Moved Temporarily\r\n")
	array.each do |line|
	  if (line =~ "Location: ([^ ]+)\r\n")
	    @url = $1
	    sock.close if sock
	    sock = TCPSocket.open("dic.lycos.co.jp", 80)
	    sock.sync = true
	    sock.printf("GET %s HTTP/1.0\r\n\r\n", @url)
	    array = sock.readlines
	    break
	  end
	end
      end
      array.each do |line|
	line = Kconv.toeuc(line)
	# ふ‐えん【<B>赴援</B>】</A>
	if !(/【<B>(.+)<\/B>】(<\/A>||<\/DIV>)/ =~ line)
	  next
	else
	  # ふ‐えん【<B>敷<sup>×</sup>衍・布<sup>×</sup>衍・敷延</B>】
	  $1.split("・").each do |word|
	    # <B>くり‐ごと</B>【<B>繰（り）言</B>】<BR><DIV>同じ事を繰り返して言うこと。特に、泣き事や不平などを、くどくどと言うこと。また、その言葉。「―を聞かされる」</DIV>
	    if /(.*)（([^ぁ-ん])）(.*)/ =~ word
	      temp = word
	      while /(.*)（([^ぁ-ん])）(.*)/ =~ temp
		# with all characters with parens
		temp = $1 + $2 + $3
	      end
	      v.push(temp) if !v.include?(temp)
	      temp = word
	      while /(.*)（([^ぁ-ん])）(.*)/ =~ temp
		# without characters with parens
		temp = $1 + $3
	      end
	      v.push(temp) if !v.include?(temp)
	      # XXX with/without characters with parens
	    else
	      v.push(word) if !v.include?(word)
	    end
	  end
	end
      end
    ensure
      sock.close if sock
    end
    v
  end

  def search_with_okuri_process(key, candidate, switch)
    # SWITCH 0 == daijisen, 1 == datapal
    #key := 'そぶr', candidate := '素振'
    return false unless /^([ーぁ-ん]+)([a-z])$/ =~ key
    key = $1 #'そぶ'
    if !(okurigana = Okurigana[$2])
      return false
    else
      okurigana.each do |char|
	if switch == 0
	  if search_daijisen(key + char).include?(candidate + char)
	    return (key + char) + "," + (candidate + char)
	  end
	elsif switch == 1
	  if search_pal(key + char).include?(candidate + char)
	    return (key + char) + "," + (candidate + char)
	  end
	end
      end
    end
    false
  end

  def search_pal(key)
    return false if key.nil?
    key = cut_off_prefix_postfix(key)
    v = Array.new
    begin
      sock = TCPSocket.open("dic.lycos.co.jp", 80)
      # pal == データパル 新語辞典
      sock.sync = true
      @url = "http://dic.lycos.co.jp/pal/list.html?query=#{CGI::escape(Kconv.toeuc(key))}&encoding=euc-japan"
      sock.printf("GET %s HTTP/1.0\r\n\r\n", @url)
      array = sock.readlines
      if (array[0] == "HTTP/1.1 302 Moved Temporarily\r\n")
	array.each do |line|
	  if line =~ "Location: ([^ ]+)\r\n"
	    @url = $1
	    sock.close if sock
	    sock = TCPSocket.open("dic.lycos.co.jp", 80)
	    sock.sync = true
	    sock.printf("GET %s HTTP/1.0\r\n\r\n", @url)
	    array = sock.readlines
	    break
	  end
	end
      end
      array.each do |line|
	line = Kconv.toeuc(line)
	# <LI VALUE="1"><A HREF="/pal/result.html?query=%83o%83C%83I&id=0001003861&encoding=shift-jis">生命誌研究館</A>
	if (/<LI VALUE=\"[0-9]+\"><A HREF=.+encoding=euc-japan\">([^<>]+)<\/A>/ =~ line) ||
	  #<B>特許庁</B><BR>
	  #
	  #とっきょちょう</DIV>
	    (/<B>([^<>]+)<\/B><BR>\n#{key}<\/DIV>/ =~ line)
	  v.push($1)
	end
      end
    ensure
      sock.close if sock
    end
    v
  end

end
# end of lycosdict.rb
