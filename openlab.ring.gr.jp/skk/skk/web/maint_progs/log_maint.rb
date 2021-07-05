#!/usr/local/bin/ruby -Ke
##!/usr/bin/ruby
#
# Copyright (C) 2002, 2003, 2004 Mikio NAKAJIMA <minakaji@osaka.email.ne.jp>
#
# Author: Mikio NAKAJIMA <minakaji@osaka.email.ne.jp>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: log_maint.rb,v 1.26 2004/07/19 20:17:16 skk-cvs Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2004/07/19 20:17:16 $

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

#require 'cgi-lib'
require 'csv'
require 'dbm'
require 'kconv'

require 'fl'
require 'goodict' # requires 'cgi'
require 'logdic'
require 'lycosdict'
require 'expr2'

Log_Maint_Debug = false #true
UpdateHukugougo = false #true
Regratio_dbmfile = '/usr/home/minakaji/log/regreqratio'

def make_new_log()
  if Log_Maint_Debug
    logdir        = '/usr/home/minakaji/tmp/'
    tmpdir        = logdir
    skkdic        = logdir + 'log_maint_' + "#{Process.pid}" + '.00'
    lockdirname   = logdir + 'registdic.log.lock'
    logfilename   = logdir + 'registdic.log'
    commandprefix = '/usr/home/minakaji/bin/skkdic-expr2 ' + skkdic + ' ^ '
  else
    logdir        = '/circus/openlab/skk/log/'
    tmpdir        = '/circus/openlab/skk/tmp/'
    skkdic        = tmpdir + 'log_maint_' + "#{Process.pid}" + '.00'
    lockdirname   = tmpdir + 'registdic.log.lock'
    logfilename   = logdir + 'registdic.log'
    commandprefix = '/usr/home/minakaji/bin/skkdic-expr2 ' + skkdic + ' ^ '
  end
  locked = false
  count = 0
  while (!locked && 100 > count)
    filelock = FileLockDir.new
    locked = filelock.lock(lockdirname)
    count += 1
    sleep(5)
  end
  return false if !locked
  logarray = Array.new
  ldic = '/circus/openlab/skk/skk/dic/SKK-JISYO.L'
  jinmeidic = '/circus/openlab/skk/skk/dic/SKK-JISYO.jinmei'
  wrongdic = '/circus/openlab/skk/skk/dic/SKK-JISYO.wrong.annotated'
  notwrongdic = '/circus/openlab/skk/skk/dic/SKK-JISYO.not_wrong'
  noregistdic = '/circus/openlab/skk/skk/dic/SKK-JISYO.noregist'
  if UpdateHukugougo
    hukugougodic = '/circus/openlab/skk/skk/dic/SKK-JISYO.hukugougo'
  end
  begin
    File.rename(logfilename, logfilename + '.BAK')
    # read the current registdic.log into logarray
    File.foreach(logfilename + '.BAK') do |line|
      key,candidate,hinsi,yourei,goodict,lycosdict,date,search_engine_cache,rhost,raddr,dummy,goo_num = csv_split(line.chomp)
      key = csv_quote(key)
      candidate = csv_quote(candidate)
      yourei = csv_quote(yourei)
      search_engine_cache = csv_quote(search_engine_cache)
      goo_num = '"' + goo_num + '"' if goo_num =~ /[0-9]/
      logarray.push([key,candidate,hinsi,yourei,goodict,lycosdict,date,search_engine_cache,rhost,raddr,dummy,goo_num])
    end
    File.open(skkdic, 'w') do |skk_file_handler|
      logarray.each do |array|
	skk_file_handler.print array[0], ' /', array[1], "/\n"
      end
    end
    # make hash file for each dictionary in the cvs repositry.
    ldichash = make_union(ldic, skkdic)
    jinmeidichash = make_union(jinmeidic, skkdic)
    wrongdichash = make_union(wrongdic, skkdic)
    notwrongdichash = make_union(notwrongdic, skkdic)
    noregistdichash = make_union(noregistdic, skkdic)
    if UpdateHukugougo
      hukugougodichash = make_union(hukugougodic, skkdic)
    end
    File.unlink(skkdic)
    # write the contents of logarray into a new registdic.log
    File.open(logfilename, 'w') do |new_file_handler|
      logarray.each do |array|
	key = array[0]
	candidate = array[1]
	hinsi = array[2]
	if !(key && candidate)
	  next
	end
	if (
	    # wrong 辞書に載っているか、
	    ((v = wrongdichash[key]) && v.include?(candidate)) ||
	    # noregist 辞書に載っているか、
	    ((v = noregistdichash[key]) && v.include?(candidate)) ||
	    # UpdateHukugougo が true で hukugougodic 辞書に載っているか、
	    (UpdateHukugougo && (v = hukugougodichash[key]) && v.include?(candidate)) ||
	    # 誤登録で not_wrong 辞書に載っているか、
	    ((hinsi == "誤登録") && (v = notwrongdichash[key]) &&
	     v.include?(candidate)) ||
	    # 誤登録で L 辞書からはもう削除されたか、
	    ((hinsi == "誤登録") && (v = ldichash[key]) &&
	     !(v.include?(candidate))) ||
	    # hinsi が人名に関するもので、jinmei 辞書に登録済みか、
	    (["姓", "名", "その他の人名(フルネームなど)"].include?(hinsi) &&
	     (v = jinmeidichash[key]) && v.include?(candidate)) ||
	    # もしくは、hinsi が誤登録でも人名に関するものでもなく、L 辞書に登録済みの場合は
	    (!["誤登録", "姓", "名", "その他の人名(フルネームなど)"].include?(hinsi) &&
	     (v = ldichash[key]) && v.include?(candidate)))
	  # 消す...nothing to do
	else
	  # それ以外の場合は書き戻す。
	  new_file_handler.print array.join(',') + ",\n"
	end
      end
    end
  ensure
    filelock.unlock(lockdirname) if locked
  end
end

def make_union(file0, file1)
  # make hash file for each dictionary in the cvs repositry.
  hash = Hash.new
  if Log_Maint_Debug
    tmpdir = '/usr/home/minakaji/tmp/'
  else
    tmpdir = '/circus/openlab/skk/tmp/'
  end
  skkdic  = tmpdir + 'log_maint_' + "#{Process.pid}" + '.01'
  command = '/usr/home/minakaji/bin/skkdic-expr2 ' + file0 + ' ^ ' + file1 + '>' + skkdic
  if !system(command)
    return false
  end
  File.foreach(skkdic) do |line|
    candidates = Array.new
    if (line =~ /([^ ]+) \/(.+)\//)
      key = $1
      $2.split('/').each do |can|
	if can =~ /([^;]+);.*/
	  can = $1
	end
	candidates.push(can)
      end
      hash[key] = candidates
    end
  end
  File.unlink(skkdic)
  hash
end

File.umask(000)
make_new_log

dic = Logdic.new
logdic = dic.make(false, false, true)
logdir = '/circus/openlab/skk/log/'
if !Log_Maint_Debug
  regratio_dbm = DBM.open(Regratio_dbmfile, 0666)
  begin
    Dir.foreach(logdir) do |file|
      # %A4%A2%A4%A4%A4%CF+%B0%A6%CD%D5.log
      fname = File.basename(file, '.log')
      if !(fname =~ /([^+]+)\+([^+]+)/)
	next
      end
      key = CGI::unescape($1)
      word = CGI::unescape($2)
      if (!logdic.key?(key) || !logdic[key].include?(word))
	file = File.expand_path(file, logdir)
	File.unlink(file)
	print 'deleted ', file, "\n"
	if regratio_dbm[fname]
	  regratio_dbm.delete(fname)
	  print 'deleted dbm database', fname, "\n"
	end
      end
    end
  ensure
    regratio_dbm.close
  end
end

# end of log_maint.rb
