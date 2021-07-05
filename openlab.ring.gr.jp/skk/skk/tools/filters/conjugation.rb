#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: conjugation.rb,v 1.7 2013/05/26 09:47:48 skk-cvs Exp $
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
##
### Instruction:
##
## This script generates (mainly) okuri-ari pairs derived from conjugational
## words given, using annotations designed for this purpose
## (esp. in SKK-JISYO.notes).
##
##     �֤�������u /������;�¥�Ը���[wiueot(c)]/��
##
## This pair is expanded into:
##
##     �֤�������w /������/��
##     �֤�������i /������/��
##     �֤�������u /������/��
##     �֤�������e /������/��
##     �֤�������o /������/��
##     �֤�������t /������/��
##     �֤�������c /������/�� (if -p option is given)
##
## By default, okuri-nasi pairs with one-letter 'candidate' will be expanded
## in the same manner, eg.:
##
##     �֤��� /��;�¥���̾��[��s]/��
##
##     �֤��� /��/��
##     �֤���s /��/��
##
## while -O suppress this kind of expansion, -o option allows it for
## candidates of any length:
##
##     �֤��󤳤� /����;�·���ư��[��dns]/��
##
##     �֤��󤳤� /����/��
##     �֤��󤳤�d /����/��
##     �֤��󤳤�n /����/��
##     �֤��󤳤�s /����/��
##     
##
## NOTE: skkdictools.rb should be in the loadpath of ruby.

#require 'jcode'
#require 'kconv'
require 'skkdictools'
require 'optparse'
opt = OptionParser.new

$annotation_mode = "all"
$comment_mode = "all"
parentheses = "discard"
okuri_nasi_too = "oneletter"
#okuri_strictly_output = false
purge = false

# �������롢���Ф���������ä������ɤ��������ʤ������Ϥ餷������������
# ���������������������ͤ롢���ޤ������ʤ��������������äѤʤ������롢
# �����롢���ơ��������ʤ������櫓�롢���褦��������
# ([flqvx]) - x can be useful, however it doesn't work well (�ָ����ʡ�)
all_strings = "abcdeghijkmnoprstuwyz"

# #�ˤ� /#3��/#1��/#0��/#2��/
numerative_order = [3, 1, 0, 2]

# ���� (��r /��/)
# ���� (��r /��/)
# ���Բ��� (���ꤦr /ͭ����/)
IrregularConjugationTable = [
  [ "����", "��r",
    [
      # (��) ���, ���� (,���ä�, ���ä��� (, ���ä�))
      "��r", "��n", # "��z", "��k", "��b",
      # (��) �褤, ��ʤ�, �����, �褵����, ��褦, �褺
      "��i", "��n", "��r", "��s", "��y", "��z",
      # (��) ����㤦, ��Ť餤, ��ޤ�, ���, �褽��, ���, ��䤬�ä�,
      "��c", "��d", "��m", "��n", "��s", "��t", "��y",
      # (�����ʤ�, ���Ϥ��ʤ������Ϥ�, ������, ���ä��ʤ�, ������)
      #"��e", "��h", "��i", "��k", "��o",
    ]],

  [ "����", "��r",
    [
      # (��) �٤�, �٤ޤ� (,�����, ���ä�, ���ä���)
      "��r", "��m", #"��n", "��z", "��k",
      # (��) �٤��㤨, �٤ޤ�, �٤ʤ�, �٤�, �٤���, �٤�, �٤褦
      "��c", "��m", "��n", "��r", "��s", "��t", "��y",
      # (,���ä��ʤ�, ������, ���Ť餤)
      #"��k", "��u", "��d",
      # (��) �٤�, �٤� (,����, ����)
      "��y", "��z", #"��i", "��b"
    ]],

  [ "���Բ���", "��r",
    [
      # (��) ͭ�����٤�, ͭ������
      "��b", "��r",
      # (��) �����㤦, ���ޤ�, ���ʤ�, ����, ������, ����, ���褦, ����
      "��c", "��m", "��n", "��r", "��s", "��t", "��y", "��z"
      # (,���ä���, ����, ����(��))
      #"��k", "��j", "��d",
    ]]
]

def print_pair2(key, candidate, annotation, comment, base = false)
  annotation = nil if $annotation_mode == "none" || ($annotation_mode == "self" && !base)
  comment = nil if $comment_mode == "discard" || ($comment_mode == "self" && !base)

  print_pair(key, candidate, annotation, comment)
end

opt.on('-u', "don't add annotations for derived pairs") { $annotation_mode = "self" }
opt.on('-U', 'eliminate all the annotations') { $annotation_mode = "none" }
opt.on('-c', "don't add comments for derived pairs") { $comment_mode = "self" }
opt.on('-C', 'eliminate all the comments') { $comment_mode = "discard" }
opt.on('-p', "use OKURIs in parentheses too") { parentheses = "use" }
opt.on('-o', "process okuri-nasi pairs too (eg. SAHEN verbs and adjective verbs)") { okuri_nasi_too = "all" }
opt.on('-O', "never process okuri-nasi pairs") { okuri_nasi_too = "none" }
opt.on('-x', 'skip candidates marked with "��" or "?"') { purge = true }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  next if $_ =~ /^;/ || $_ =~ /^$/
  midasi, tokens = $_.parse_skk_entry
  next if tokens.nil?

  if (/^(>?[��-�󡫡�]*)([a-z]+)$/ =~ midasi)
    stem = $1
    okuri = $2
  elsif okuri_nasi_too == "none"
    next
  else
    stem = midasi
    okuri = ""
  end

  tokens.each do |token|
    next if token.empty?
    tmp = token.split(";")
    next if tmp[1].nil?
    word = tmp[0]
    next if okuri.empty? && okuri_nasi_too == "oneletter" && word.length > 2
    annotation, comment = tmp[1].split("��", 2)
    next if comment.nil?
    next if purge && annotation =~ /��|\?$/
    comment.sub!(/��.*$/, '')

    new_index = 0
    while index = (comment[new_index .. -1] =~ /\[([^\]]*)\]/)
      old_index = new_index
      new_index += index + $1.length + 2
      derivation = $1
      if parentheses == "discard"
	derivation.gsub!(/\([^)]*\)/, '')
      else
	derivation.gsub!(/[()]/, '')
      end

      # XXX what if �֤�u /��;�����ư��[<wiueot(c)]/��?
      suffix = derivation.gsub!(/</, '')
      numerative = derivation.gsub!(/#/, '')

      if derivation == "a-z"
	derivation = all_strings 
      elsif derivation == "*"
	IrregularConjugationTable.each do |table|
	  next if !comment[old_index .. new_index].include?(table[0])
	  core = midasi.sub(table[1], '')
	  next if core == midasi # alternation failed

	  table[2].each do |tail|
	    new_midasi = "#{core}#{tail}"
	    print_pair2(new_midasi, word, annotation, comment,
			(new_midasi == midasi))
	    print_pair2(">" + new_midasi, word, annotation, comment,
			(new_midasi == midasi)) if suffix
	  end
	  break
	end
	next
      end

      if derivation.gsub!(/��/, '')
	print_pair2(stem, word, annotation, comment, (okuri == ""))
      end

      derivation += okuri if !derivation[okuri]

      derivation.delete("^a-z>").each_byte do |byte|
	new_okuri = byte.chr
	print_pair2("#{stem}#{new_okuri}", word, annotation, comment,
			(okuri == new_okuri))
	print_pair2(">#{stem}#{new_okuri}", word, annotation, comment, false) if suffix
	if numerative
	  for i in numerative_order
	    print_pair2("##{stem}#{new_okuri}", "##{i}#{word}", annotation, comment, false)
	  end
	end
      end
    end
  end
end

