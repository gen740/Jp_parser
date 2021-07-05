#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: skkdictools.rb,v 1.8 2013/05/26 09:47:48 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2013/05/26 09:47:48 $
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program, see the file COPYING.  If not, write to the
## Free Software Foundation Inc., 51 Franklin St, Fifth Floor, Boston,
## MA 02110-1301, USA.
##
### Commentary:
## Based on registdic.cgi and skkform.rb by Mikio NAKAJIMA.
## (Prolly we'd better integrate skkdictools.rb and skkform.rb into one?)
##
### Instruction:
##
## A library packed with small gadgets useful to handle skk dictionary.
##
## Most of scripts under tools/filters and some under tools/convert2skk
## require this file to be installed in one of the ruby loadpaths.
##

#require 'jcode'
#require 'kconv'

## for Goo::search
#require 'cgi'
#require 'socket'
#require 'timeout'

# exceptions:
#	["��" , "c"] (eg. �֤ˤ������ /�������/�ע��֤ˤ�c /��/��)
#	["��" , "p"] (eg. �֤ĤäѤ� /�ͤäѤ�/�ע��֤�p /��/��)
#	["��" , "c"] (eg. �֤����ä��� /��ä���/�ע��֤���c /��/��)
GyakuhikiOkurigana = [
  ["��" , "a"],
  ["��" , "b"], ["��" , "b"], ["��" , "b"], ["��" , "b"], ["��" , "b"],
  ["��" , "d"], ["��" , "d"], ["��" , "d"], ["��" , "d"], ["��" , "d"],
  ["��" , "e"],
  ["��" , "g"], ["��" , "g"], ["��" , "g"], ["��" , "g"], ["��" , "g"],
  ["��" , "h"], ["��" , "h"], ["��" , "h"], ["��" , "h"], ["��" , "h"],
  ["��" , "i"],
  ["��" , "j"],
  ["��" , "k"], ["��" , "k"], ["��" , "k"], ["��" , "k"], ["��" , "k"],
  ["��" , "m"], ["��" , "m"], ["��" , "m"], ["��" , "m"], ["��" , "m"],
  ["��" , "n"], ["��" , "n"], ["��" , "n"], ["��" , "n"], ["��" , "n"], ["��" , "n"],
  ["��" , "o"],
  ["��" , "p"], ["��" , "p"], ["��" , "p"], ["��" , "p"], ["��" , "p"],
  ["��" , "r"], ["��" , "r"], ["��" , "r"], ["��" , "r"], ["��" , "r"],
  ["��" , "s"], ["��" , "s"], ["��" , "s"], ["��" , "s"], ["��" , "s"],
  ["��" , "t"], ["��" , "t"], ["��" , "t"], ["��" , "t"], ["��" , "t"], ["��" , "t"],
  ["��" , "u"],
  ["��" , "w"], ["��" , "w"],
  ["��" , "x"], ["��" , "x"], ["��" , "x"], ["��" , "x"], ["��" , "x"],
  ["��" , "x"], ["��" , "x"], ["��" , "x"], ["��" , "x"], ["��" , "x"], ["��" , "x"],
  ["��" , "y"], ["��" , "y"], ["��" , "y"], ["��" , "y"], ["��" , "y"], ["��" , "y"],
  ["��" , "z"], ["��" , "z"], ["��" , "z"], ["��" , "z"], ["��" , "z"]
]

# ("�����䤱", "ī�Ƥ�") => ("������k", "ī��", "��")
# ("�ͤ�", "ǭ") => nil
def okuri_nasi_to_ari(midasi, candidate)
  return nil if (/(.*[^��-��])([��-��]+)$/ !~ candidate)
  can_prefix = $1
  can_postfix = $2
  return nil if !(can_prefix && can_postfix && (/(.+)#{can_postfix}$/ =~ midasi))
  key_prefix = $1
  key_kana_postfix = GyakuhikiOkurigana.assoc(can_postfix.split('')[0])
  return nil if key_kana_postfix.empty?

  okuri = key_kana_postfix[1]
  # handle some exceptions
  # XXX inplace of changing "t" into "c", this function should return
  # both "t" and "c"
  okuri = "c" if can_postfix =~ /^�ä�/ || can_postfix =~ /^��[����]/
  okuri = "p" if can_postfix =~ /^��[��-��]/
  okuri = "k" if can_postfix =~ /^��[��-��]/

  return key_prefix + okuri, can_prefix, can_postfix
end

def print_pair(key, candidate, annotation = nil, comment = nil)
  if !annotation.nil? && !annotation.empty?
    if comment.nil? || comment.empty?
      print "#{key} /#{candidate};#{annotation}/\n"
    else
      print "#{key} /#{candidate};#{annotation}��#{comment}/\n"
    end
  else
    if comment.nil? || comment.empty?
      print "#{key} /#{candidate}/\n"
    else
      print "#{key} /#{candidate};��#{comment}/\n"
    end
  end
end

# borrowed from skkform.rb
class String
  def to_katakana
    self.gsub(/����/, '\\1��').tr('��-��', '��-��')
  end

  def to_hiragana
    self.gsub(/��/, '����').tr('��-��', '��-��')
  end

  def cut_off_prefix_postfix
    self.sub(/^[<>\?]([����-��]+)$/, '\1').sub(/^([����-��]+)[<>\?]$/, '\1')
  end

  # from �֥��֥������Ȼظ�������ץȸ���ruby��p121
  def csv_split(delimiter = ',')
    csv = []
    data = ""
    self.split(delimiter).each do |d|
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

  def csv_quote
    self.gsub(/"/, '\\"').sub(/.*,.*/, '"\&"')
  end

  def csv_unquote
    self.sub(/^\"(.+)\"$/, '\1')
  end

  def concatify
    #if !(/^([-\w]+.*)$/ =~ self) && (/[;\r\n\/\"]/ =~ self)
    if /[;\r\n\/\"]/ =~ self
      tmp = self.gsub(/;/, '\\\073').gsub(/\//, '\\\057').gsub(/\r/, '\\r').gsub(/\n/, '\\n').gsub(/"/, '\\"')
      return '(concat "' + tmp + '")'
    else
      return self
    end
  end

  # 09/30/04 => 04/09/30
  def mdy2ymd
    self.sub(/^([0-9]*)\/([0-9]*)\/([0-9]*)/, '\3/\1/\2')
  end

  def parse_skk_entry
    midasi, rest = self.chop.split(" /", 2)
    tokens = rest.sub(/\/\[.*/, "").split("/") if !rest.nil?
    return midasi, tokens
  end

  def skk_split_tokens(delimiter = '��')
    word, annotation = self.split(";", 2)
    return word, nil, nil if annotation.nil?
    return word, annotation, nil if delimiter.nil?
    annotation, comment = annotation.split(delimiter, 2)
    return word, annotation, comment
  end
end

class Goo
  def search(key)
    hits = tries = 0
    key = Kconv.toeuc(key)
    key = CGI::escape(key)
    timeout(20) {
      begin
	tries += 1
	sock = TCPSocket.open("search.goo.ne.jp", 80)
	sock.printf("GET /web.jsp?DC=1&MT=\"%s\" HTTP/1.0\r\n\r\n", key)
	sock.readlines.each do |line|
	  line = Kconv.toeuc(line)
	  if (/<b>��*([,0-9]+)<\/b>����/ =~ line)
	    hits = $1.gsub(/,/, '').to_i
	    return hits if hits > 0
	  # 0hits, or system error?
	  elsif (/<br>�������븡����̤���������ޤ���/ =~ line)
	  #elsif (/<br>���������ƥफ�鸡����̤�����˼����Ǥ��ʤ��ä���ǽ��������ޤ���/ =~ line) next
	    return 0
	  end
	end
      ensure
	sock.close if sock
      end while tries < 3 && hits < 1
    }
    "unknown"
  end
end

