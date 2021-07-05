#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: prime2skk.rb,v 1.6 2013/05/26 09:47:48 skk-cvs Exp $
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
## This script tries to convert PRIME dictionary files into skk ones.
##
##    % prime2skk.rb prime-dict | skkdic-expr2 > SKK-JISYO.prime
##
##    % prime2skk.rb -Ag prime-dict | conjugation.rb -opUC | skkdic-expr2 > SKK-JISYO.prime.conjugation
##
## -g and -A given, this script can append grammatical annotations useful in
## combination with conjugation.rb.
## 
## NOTE: skkdictools.rb should be in one of the ruby loadpaths.
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
unannotate = false

opt.on('-a', "convert Asayake into AsayaKe") { asayake_mode = "convert" }
opt.on('-A', "both Asayake and AsayaKe are output") { asayake_mode = "both" }
opt.on('-g', "append grammatical annotations") { grammar = true }
opt.on('-k', "generate hiragana-to-katakana pairs (�֤ͤ� /�ͥ�/��)") { skip_hira2kana = false }
opt.on('-K', "generate identical pairs (�֤ͤ� /�ͤ�/��)") { skip_identical = false }
opt.on('-u', "don't add original comments as annotation") { unannotate = true }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  #line = $_.toeuc
  key, hinsi, candidate, score, notes = $_.split("	", 5)
  # ���礦����	̾��	����	377	comment=state	usage=��Τ��Ȥ��ͻҡ��־����Ѳ���
  next if skip_identical && key == candidate
  next if skip_hira2kana && key.to_katakana == candidate

  comment = nil
  if grammar
    comment = hinsi
    comment += "[��>]" if hinsi =~ /��Ƭ��/
    comment += "[��#]" if hinsi =~ /������/
    comment += "[��<]" if hinsi =~ /������/
  end

  print_orig = true
  okuri = ""
  comment_extra = ""
  notes.chop!.gsub!(/	/, ",") if !notes.nil?

  if asayake_mode != "none"
    new_key, new_candidate, postfix = okuri_nasi_to_ari(key, candidate)
    if !new_key.nil?
      if grammar
	comment_extra += "(-#{postfix})"

	if (hinsi =~ /̾��/ ||
	    hinsi =~ /����/ ||
	    hinsi =~ /Ϣ�λ�/ ||
	    hinsi =~ /�θ�/ )
	  print_orig = true
	else
	  print_orig = false
	end
      end
      print_pair(new_key, new_candidate, unannotate ? nil : notes,
		  comment.delete("��") + comment_extra)
      print_orig = false if asayake_mode != "both"
    elsif grammar
      # XXX XXX Unfortunately, prime-dict doesn't have data of exact
      # conjugation types for adjective verbs; this should yield a lot of
      # unwanted okuri-ari pairs, such as �֤ɤ��ɤ�n /Ʋ��/��(�������).
      comment += "[��dn(st)]" if hinsi =~ /����ư��/
      comment += "[��s]" if hinsi =~ /����\(����\)/

      if hinsi =~ /([��-��])�Ը���/
	okuri = GyakuhikiOkurigana.assoc($1.to_hiragana)[1]
      end

      if hinsi =~ /���ƻ�/
	comment += "[iks(gm)]" 
	okuri = "i"
      elsif hinsi =~ /��Ը���/
	comment += "[wiueot(c)]"
	okuri = "u"
      elsif hinsi =~ /���Ը���/
	comment += "[gi]"
      elsif hinsi =~ /���Ը���/
	#if candidate =~ /��$/
	if key =~ /��$/
	  comment += "[ktc]"
	elsif key =~ /��$/
	  comment += "[k]"
	else
	  comment += "[ki]"
	end
      elsif hinsi =~ /�޹Ը���/
	comment += "[mn]"
      elsif hinsi =~ /��Ը���/
	comment += "[rt(cn)]"
      elsif hinsi =~ /��\(��\)/
	comment += "[*]"
	okuri = "r"
      elsif hinsi =~ /����/
	# this can be of problem
	comment += "[a-z]"
	okuri = "r"
      end
    end
  end
  print_pair(key + okuri, candidate, unannotate ? nil : notes, grammar ? comment : nil) if print_orig
end
