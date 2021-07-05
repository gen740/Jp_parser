#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: ipadic2skk.rb,v 1.4 2013/05/26 09:47:48 skk-cvs Exp $
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
### Instruction:
##
## This script tries to convert IPADIC dictionary files into skk ones.
##
##     % ipadic2skk.rb ipadic-2.7.0/Noun.name.dic | skkdic-expr2 > SKK-JISYO.ipadic.jinmei
##
## would yield a lot of nifty jinmei additions.
##
##     % ipadic2skk.rb -Ag ipadic-2.7.0/Verb.dic | conjugation.rb -opUC | skkdic-expr2 > SKK-JISYO.ipadic.verb
##
## With -g and -A options, this script can append grammatical annotations
## useful in combination with conjugation.rb.
##
## NOTE: skkdictools.rb should be in the ruby loadpaths to have this work.
##
require 'jcode' if RUBY_VERSION.to_f < 1.9
#require 'kconv'
require 'skkdictools'
require 'optparse'
opt = OptionParser.new
skip_identical = true
skip_hira2kana = true
grammar = false
asayake_mode = "none"

opt.on('-a', "convert Asayake into AsayaKe") { asayake_mode = "convert" }
opt.on('-A', "both Asayake and AsayaKe are output") { asayake_mode = "both" }
opt.on('-g', "append grammatical annotations") { grammar = true }
opt.on('-k', "generate hiragana-to-katakana pairs (�֤ͤ� /�ͥ�/��)") { skip_hira2kana = false }
opt.on('-K', "generate identical pairs (�֤ͤ� /�ͤ�/��)") { skip_identical = false }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  #line = $_.toeuc
  next if $_ !~ /^\(�ʻ� \(([^)]*)\)\) \(\(���Ф��� \(([^ ]*) [0-9]*\)\) \(�ɤ� ([^ ]*)\)/
  # (�ʻ� (̾�� ����)) ((���Ф��� (�ز� 3999)) (�ɤ� ���å�) (ȯ�� ���å�) )
  next if skip_hira2kana && $2 == $3
  hinsi = $1
  candidate = $2
  key = $3.tr('��-��', '��-��').gsub(/��/, '����')
  next if skip_identical && key == candidate

  conjugation = nil
  if grammar && $_ =~ /\(���ѷ� ([^)]*)\) \)$/
    # (���ѷ� ���ʡ����¥����) )
    conjugation = $1.sub(/^(..)��([��-��]��)/, '\2\1 ')
  end

  comment = nil
  if grammar
    comment = hinsi
    comment += " " + conjugation if !conjugation.nil?
    if hinsi =~ /��Ƭ��/
      if hinsi =~ /����³/
	# generate "#0"; complete-numerative.rb should do the rest
	candidate += "#0"
	key += "#"
      else
	comment += "[��>]"
      end
    elsif hinsi =~ /����/
      if hinsi =~ /������/
	comment += "[��#]"
      else
	comment += "[��<]"
      end
    end
  end

  tail = ""
  if key =~ /^\{(.*)\}([��-��]*)$/
    tail = $2
    # (�ɤ� {���ͥ�/���ͥ�})
    keys = $1.split("/")
  else
    keys = key
  end

  keys.each do |midasi|
    midasi += tail if !tail.nil?
    next if skip_identical && midasi == candidate
    print_orig = true

    if asayake_mode != "none"
      new_midasi, new_candidate, postfix = okuri_nasi_to_ari(midasi, candidate)
      if !new_midasi.nil?
	comment_extra = ""
	if grammar
	  comment_extra += "[iks(gm)]" if postfix == "��" && hinsi =~ /���ƻ�/

	  comment_extra += "[wiueot(c)]" if postfix == "��" && conjugation =~ /��Ը���/
	  comment_extra += "[gi]" if postfix == "��" && conjugation =~ /���Ը���/
	  comment_extra += "[mn]" if postfix == "��" && conjugation =~ /�޹Ը���/
	  comment_extra += "[*]" if postfix == "��" && conjugation =~ /����/
	  comment_extra += "[rt(cn)]" if postfix == "��" && conjugation =~ /��Ը���/
	  # this can be of problem
	  comment_extra += "[a-z]" if postfix == "��" && conjugation =~ /����/

	  #comment_extra += "[ki]" if postfix == "��" && conjugation =~ /���Ը���/
	  if postfix == "��" && conjugation =~ /���Ը���/
	    #if new_candidate =~ /��$/
	    if new_midasi =~ /��k$/
	      comment_extra += "[ktc]"
	    elsif new_midasi =~ /��k$/
	      comment_extra += "[k]"
	    else
	      comment_extra += "[ki]"
	    end
	  end

	  comment_extra += "(-#{postfix})"
	  #print_orig = false if !comment_extra.empty?
	  print_orig = false if hinsi =~ /ư��|���ƻ�/
	end
	print_pair(new_midasi, new_candidate, nil,
		    comment.delete("��") + comment_extra)
	print_orig = false if asayake_mode != "both"
      else
	comment += "[��dn(s)]" if hinsi =~ /����ư��촴/
	comment += "[��s]" if hinsi =~ /������³/
      end
    end
    print_pair(midasi, candidate, nil, grammar ? comment : nil) if print_orig
  end
end
