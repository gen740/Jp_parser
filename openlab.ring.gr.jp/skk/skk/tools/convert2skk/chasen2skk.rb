#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: chasen2skk.rb,v 1.5 2013/05/26 09:47:48 skk-cvs Exp $
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
## This script tries to extract SKK pairs from the output of ChaSen.
##
## % chasen | chasen2skk.rb
## or
## % mecab -Ochasen | chasen2skk.rb
##
##
## skkdictools.rb required.
##
## TODO: pick up compound-verbs, eg. ���񤤻����
## ��    �ޥ�    ��    ư��-��Ω       ���ʡ����¥����        Ϣ�ѷ�
## ����    ����    ����    ư��-��Ω       ���ʡ����      ���ܷ�
##
require 'jcode' if RUBY_VERSION.to_f < 1.9
require 'kconv'
require 'skkdictools'

#require 'cgi'
#require 'socket'
#require 'timeout'

require 'optparse'
opt = OptionParser.new

katakana_words = false
#katakana_majiri = false
#append_goohits = false
keyword = ""
#fetch_from_goo = false
append_notes = false
allow_noun_chains = true
#allow_verb_chains = true
handle_prefix = true
min_length = 2 * 2
max_length = 100 * 2

# -g might be a bad idea; better eliminate pairs already in SKK-JISYO.L first
#opt.on('-g', 'append goo hit numbers') { append_goohits = true }
opt.on('-k', '--extract-katakana', 'extract katakana words (if WORD not given)') { katakana_words = true }
#opt.on('-K', 'extract words containing katakana') { katakana_majiri = true }
opt.on('-m VAL', '--min-length=VAL', 'ignore words less than VAL letters') { |v| min_length = v.to_i * 2 }
opt.on('-M VAL', '--max-length=VAL', 'ignore words more than VAL letters') { |v| max_length = v.to_i * 2 }
opt.on('-n', '--append-notes', 'append grammatical notes') { append_notes = true }
opt.on('-N', '--disallow-noun-chains', 'disallow noun chains containing hiragana') { allow_noun_chains = false }
opt.on('-P', '--ignore-prefixes', 'don\'t take prefixes into consideration') { handle_prefix = false }
opt.on('-w WORD', '--extract-word=WORD', 'extract pairs containing WORD') { |v| keyword = v }
#opt.on('-W WORD', 'query goo and extract pairs containing WORD') { |v| keyword = v; fetch_from_goo = true }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

#keyword_pat = Regexp.compile("[��-��]*#{keyword}[��-��]*")

count = 0
#key = word = last_key = last_word = last_part = ""
key = word = last_part = ""
poisoned = terminate = false

while gets
  midasi, yomi, root, part, conj = $_.split("	", 5)
  #if midasi !~ /^[��-����-�����]+$/ || terminate
  if (midasi !~ /^[��-����-�������]+$/ &&
      (!allow_noun_chains || part !~ /̾��/ || part =~ /��Ω/ ||
      midasi !~ /^[��-����-���������-��]+$/ )) || terminate
  #if (midasi !~ /^[��-����-�����]+$/ && conj !~ /Ϣ�ѷ�/) || terminate
    #next if count < 1
    if count < 1
      next if !handle_prefix
      if part =~ /��Ƭ��/
	# kludge - keep prefix w/o increasing count (cf.�֤�Ω�ɡס֤�̣����)
	key = yomi.to_hiragana
	word = midasi
	last_part = part
      #elsif part =~ /��Ω/ && conj =~ /Ϣ�ѷ�/
      #  hogehoge
      else
	key = word = last_part = ""
      end
      next
    end

    if midasi =~ /^[^��-����-�������]+$/ && !terminate
      # nothing
    else
      if part =~ /��³��|��Ƭ��|����[^��]/
	# nothing - decline some parts
      elsif midasi =~ /�¤�|�ڤ�/
	# nothing - (HACK) decline conjonctions that ChaSen overlooks
      elsif midasi =~ /^[��-��]+[��-����-�������]+/
	# nothing - this applies to quasi-words such as:
	# �˴ؤ���        �˥��󥹥�      �˴ؤ���        ����-�ʽ���-Ϣ��
      else
	key += yomi.to_hiragana
	word += midasi
	last_part = part
	# asayaKify here?
      end
    end

    if word =~ /^[��-��]+$/
      # nothing
    elsif !katakana_words && word =~ /^[��-�����]+$/
      # nothing
    elsif !keyword.empty? && !word.include?(keyword)
      # nothing
    elsif poisoned || word.size < min_length || word.size > max_length
      # nothing
    else
      print_pair(key, word, nil, append_notes ? "<autogen>,#{last_part.chomp}" : nil)
    end

    key = word = last_part = ""
    poisoned = terminate = false
    count = 0

  else
    if count > 0 && part =~ /��³��|��Ƭ��|����[^��]/
      terminate = true
      redo
    elsif count == 0 && part =~ /����/
      # avoid generating �ֲ����� from ���裳������
      # ��      ����    ��      ̾��-����-������
      key = word = last_part = ""
      next
    end
    count += 1
    key += yomi.to_hiragana
    word += midasi
    last_part = part
    poisoned = true if part =~ /̤�θ�/
  end
end
