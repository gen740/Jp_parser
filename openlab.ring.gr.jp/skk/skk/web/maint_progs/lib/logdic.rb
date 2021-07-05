# Copyright (C) 2002, 2003, 2004 Mikio NAKAJIMA <minakaji@osaka.email.ne.jp>
#
# Author: Mikio NAKAJIMA <minakaji@osaka.email.ne.jp>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: logdic.rb,v 1.10 2004/07/31 00:46:14 skk-cvs Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2004/07/31 00:46:14 $

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
# registdic.log を読み取り、新しいエントリを作るのに必要な情報だけを取
# り出して hash を作り返します。
require 'csv'

# for debugging
Logdic_Debug = false #true
if Logdic_Debug
  Logdic_Logfilename = './registdic.log'
else
  Logdic_Logfilename = '/circus/openlab/skk/log/registdic.log'
end

class Logdic

  def make(wrong = false, annotation = true, all = false)
    # if wrong is true, pick up wrong entries only.
    pickup = Hash.new
    File.foreach(Logdic_Logfilename) do |line|
      key,candidate,hinsi,yourei,daijirin,shingo = csv_split(line)
      if !(key && candidate)
	next
      elsif all	||
	  ((!wrong && !(hinsi == '誤登録') && (daijirin == '○' || shingo == '○')) ||
	   (wrong && (hinsi == '誤登録') && !(daijirin == '○' || shingo == '○')))
	if annotation && ((yourei && !yourei.empty?) || (hinsi == '地名'))
	  if /^;/ =~ yourei
	    yourei = nil
	  elsif /[;\r\n\/\"]/ =~ yourei
	    yourei = yourei.gsub(/([^~]+);/, '\1\\\073').gsub(/\//, '\\\057').gsub(/\r/, '\\r').gsub(/\n/, '\\n').gsub(/"/, '\\"')
	    yourei = '(concat "' + yourei + '")'
	  end
	  # annotation format
	  if (hinsi == '地名')
	    candidate = candidate + ';地名'
	    if yourei
	      candidate = candidate + ',' + yourei
	    end
	  elsif yourei
	    candidate = candidate + ';' + yourei
	  else
	    # nothing to do...
	  end
	end
	# it is possible that the same key has two or more keys...
	pickup[key] = Array.new if !pickup[key]
	pickup[key].push(candidate)
      end
    end
    pickup
  end

  def make_jinmei(annotation = true, add_yourei = true)
    pickup = Hash.new
    File.foreach(Logdic_Logfilename) do |line|
      key,candidate,hinsi,yourei = csv_split(line)
      if !(key && candidate)
	next
      elsif ["姓", "名", "その他の人名(フルネームなど)"].include?(hinsi)
	if hinsi == 'その他の人名(フルネームなど)'
	  hinsi = '人名'
	end
	if !annotation
	  # nothing to do...
	elsif !add_yourei || !yourei || yourei.empty?
	  candidate = candidate + ";" + hinsi
	elsif (yourei && !yourei.empty?)
	  candidate = candidate + ";" + hinsi
	  if /^;/ =~ yourei
	    yourei = nil
	  elsif /[;\r\n\/\"]/ =~ yourei
	    yourei = yourei.gsub(/;/, '\\\073').gsub(/\//, '\\\057').gsub(/\r/, '\\r').gsub(/\n/, '\\n').gsub(/"/, '\\"')
	    yourei = '(concat "' + yourei + '")'
	  end
	  if yourei
	    candidate = candidate + "," + yourei
	  end
	end
	# it is possible that the same key has two or more keys...
	pickup[key] = Array.new if !pickup[key]
	pickup[key].push(candidate)
      end
    end
    pickup
  end

end
# end of logdic.rb
