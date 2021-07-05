# Copyright (C) 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: expr2.rb,v 1.1 2003/12/02 11:04:19 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance, manued
# Last Modified: $Date: 2003/12/02 11:04:19 $

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
# skkdic-expr2 を使用した cvs repositry 上の辞書検索ライブラリ

require 'kconv'
Expr2_Debug = false

class Expr2
  def initialize(file)
    # @dic = '/circus/openlab/skk/skk/dic/SKK-JISYO.L'
    if !File.exist?(file)
      raise "Cannot find out #{file}!"
    end
    @dic = file
  end

  def include?(key, word)
    if !(key && !key.empty?)
      return false
    end
    expr2 = '/usr/home/minakaji/bin/skkdic-expr2'
    if Expr2_Debug
      tmpdir = '/usr/home/minakaji/tmp/'
    else
      tmpdir = '/circus/openlab/skk/tmp/'
    end
    tmpfile_base = tmpdir + 'expr2_' + "#{Process.pid}"
    result_string = false
    key = Kconv.toeuc(key)
    word = Kconv.toeuc(word)
    tmpfile0 = tmpfile_base + '.00'
    tmpfile1 = tmpfile_base + '.01'
    File.open(tmpfile0, "w+") do |file_handler|
      file_handler.print "#{key} /#{word}/\n"
    end
    command = expr2  + ' ' + tmpfile0 + ' ^ ' + @dic + ' >' + tmpfile1
    begin
      if system(command)
	File.foreach(tmpfile1) do |line|
	  if (line =~ /#{key} \/#{word}(;[^\/]+)*\//o)
	    return line.chomp
	  end
	end
      end
      File.unlink(tmpfile0)
      File.unlink(tmpfile1)
    rescue Exception
    end
    return false
  end

  def union(hashdic)
    expr2 = '/usr/home/minakaji/bin/skkdic-expr2'
    if Expr2_Debug
      tmpdir = '/usr/home/minakaji/tmp/'
    else
      tmpdir = '/circus/openlab/skk/tmp/'
    end
    tmpfile_base = tmpdir + 'expr2_' + "#{Process.pid}"
    hash = Hash.new
    tmpfile0 = tmpfile_base + '.00'
    tmpfile1 = tmpfile_base + '.01'
    File.open(tmpfile0, "w+") do |file_handler|
      hashdic.sort.each do |array|
	file_handler.print "#{array[0]} /#{array[1].join('/')}/\n"
      end
    end
    command = expr2  + ' ' + @dic + ' ^ ' + tmpfile0 + ' >' + tmpfile1
    begin
      print command, "\n"
      if system(command)
	File.foreach(tmpfile1) do |line|
	  if (line =~ /([^ ]+) \/(.+)\//)
	    key = $1
	    candidates = $2
	    hash[key] = candidates.split('/')
	  end
	end
      end
    rescue Exception
      File.unlink(tmpfile0)
      File.unlink(tmpfile1)
    end
    return hash
  end

  def midasi_search(key)
    File.foreach(@dic) do |line|
      line.chomp!
      if line =~ /^#{key} /
	return line
      end
    end
    return false
  end

  def grep(regexp)
    v = Array.new
    File.foreach(@dic) do |line|
      line.chomp!
      v.push(line) if line =~ /#{regexp}/o
    end
    v
  end

end

# end of cvsdic.rb
