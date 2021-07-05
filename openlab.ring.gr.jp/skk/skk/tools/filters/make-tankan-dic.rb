#!/usr/local/bin/ruby -Ke
# -*- coding: euc-jp -*-
## Copyright (C) 2006 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: make-tankan-dic.rb,v 1.2 2013/05/26 09:47:48 skk-cvs Exp $
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
## % make-tankan-dic.rb SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.tankan
##
## This would generate a compact single chinese-letter (tankanji) dictionary
## useful in combination with skk-tankan.el.
## 
## (add-to-list 'skk-search-prog-list
##  '(skk-tankan-search 'skk-search-jisyo-file
## 	 "~/skk/dic/SKK-JISYO.tankan" 0))
##
##
## XXX This won't work with SKK-JISYO.JIS3_4; helas, ruby basically cannot
## handle JISX0213!
## 
require 'jcode' if RUBY_VERSION.to_f < 1.9
#require 'kconv'
require 'skkdictools'
require 'optparse'
opt = OptionParser.new

keep_annotation = true
purge = false
min_size = 2
max_size = 2


opt.on('-u', 'remove annotations') { keep_annotation = false }
opt.on('-p', 'purge candidates marked with "��" or "?"') { purge = true }
opt.on('-m VAL', 'minimal size of each word (in byte)') { |i| min_size = i.to_i }
opt.on('-M VAL', 'maximal size of each word (in byte)') { |i| max_size = i.to_i }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end


while gets
  next if $_ =~ /^;/ || $_ =~ /^$/ || $_ !~ /^[��-��]/
  midasi, tokens = $_.parse_skk_entry

  notyet = true
  tokens.each do |token|
    word, annotation, comment = token.skk_split_tokens
    next if word.size < min_size || word.size > max_size
    next if purge && annotation =~ /��/
    next if purge && annotation =~ /\?$/
    # TODO: check if it's `Kanji'
    if notyet
      notyet = false
      print midasi, " /"
    end
    print word
    print ";", annotation if keep_annotation && !annotation.nil? && !annotation.empty?
    print "/"
  end
  print "\n" if !notyet
end
