#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: skk-wordpicker.rb,v 1.5 2013/05/26 09:47:48 skk-cvs Exp $
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
## This script tries to extract SKK pairs from text files given.
##
## skkdictools.rb and KAKASI are required.
##
require 'jcode' if RUBY_VERSION.to_f < 1.9
require 'kconv'
require 'skkdictools'

require 'cgi'
require 'socket'
require 'timeout'

require 'optparse'
opt = OptionParser.new

Kakasi_rectify_table = [
  [ "���$", "��$", "����", "��"],
  [ "���$", "ʪ$", "�֤�", "ʪ"],
  [ "�ޤ�$", "��$", "", ""],
  [ "����$", "��$", "����", "��"],
  [ "����$", "��$", "�ऱ", "��"]
]

katakana_words = false
katakana_majiri = false
katakana_only = false
append_goohits = false
keyword = ""
#fetch_from_goo = false
append_notes = false

# -g might be a bad idea; better eliminate pairs already in SKK-JISYO.L first
opt.on('-g', 'append goo hit numbers') { append_goohits = true }
opt.on('-k', 'extract katakana words (if WORD not given)') { katakana_words = true }
opt.on('--katakana-only', 'extract katakana words only') { katakana_only = katakana_words= true } # this doens't require KAKASI
opt.on('-K', 'extract words containing katakana') { katakana_majiri = true }
opt.on('-n', 'append notes') { append_notes = true }
opt.on('-w WORD', 'extract pairs containing WORD') { |v| keyword = v }
#opt.on('-W WORD', 'query goo and extract pairs containing WORD') { |v| keyword = v; fetch_from_goo = true }

begin
  opt.parse!(ARGV)
  #rulesets = default_rulesets if rulesets.empty?
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

keyword_pat = Regexp.compile("[��-����]*#{keyword}[��-����]*")
#kanji_pat = "[
results = []


# XXX cannot handle linebreaks correctly
while gets
  # eliminate HTML tags
  #$_.gsub!(/<[^>]*>/, '') # it was too much
  $_.gsub!(/<[\/]*b>/, '')

  if keyword.empty?
    results = results + $_.scan(/[��-���][��-�����]+/) if katakana_words
    next if katakana_only
    if katakana_majiri
      results = results + $_.scan(/[��-�����]*[��-����]+[��-�����]*/)
    else
      results = results + $_.scan(/[��-����]{2,}/)
    end
  else
    #next if $_ !~ /([��-��]*����[��-��]*)/
    #results = results + $_.scan(/[��-��]*����[��-��]*/)
    results = results + $_.scan(keyword_pat)
  end
end

goo = Goo.new if append_goohits
results.uniq!
results.each {|word|
  # decline one-letter words
  next if word.size < 3
  if katakana_only
    # efficiency
    yomi = word.to_hiragana
  else
    yomi = `echo "#{word}"|kakasi -JH -KH`.chomp!
  end

  Kakasi_rectify_table.each do |table|
    key_exp  = Regexp.compile(table[0])
    word_exp = Regexp.compile(table[1])
    next if yomi !~ key_exp || word !~ word_exp

    yomi.sub!(key_exp,  table[2])
    word.sub!(word_exp, table[3])
  end

  if append_goohits
    hits = goo.search(word)
    print_pair(yomi, word, nil, append_notes ? "<autogen>,#{hits}" : "#{hits}")
  else
    print_pair(yomi, word, nil, append_notes ? "<autogen>" : nil)
  end
}
