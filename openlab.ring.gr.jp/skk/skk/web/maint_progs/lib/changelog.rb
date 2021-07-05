# Copyright (C) 2002, 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: changelog.rb,v 1.9 2003/12/02 11:04:19 minakaji Exp $
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
require 'nkf'
require 'expr2'

class ChangeLog

  def make(jisyo_filename, logdic, add = true, fold = false)
    @hash = make_dichash(jisyo_filename)
    @logdic = logdic.sort # change hash to array.
    changelog = Time.now.strftime("%Y-%m-%d")
    changelog += "  SKK Development Team <skk@ring.gr.jp>\n\n\t* " + File.basename(jisyo_filename) + ": "
    if add
      changelog += make0(fold)
    else
      changelog += make_wrong(fold)
    end
    changelog
  end

  def make0 (fold)
    addition = Hash.new
    modification = Hash.new
    changelog = ""
    @logdic.each do |container| # �������ɤ߹��������
      key = container[0]
      logdic_candidate = container[1].join("/")
      largedic_candidate = @hash[key]
      if largedic_candidate # ���Ф�������
	largedic_candidate = largedic_candidate.join('/')
	modification[key] = " /" + largedic_candidate + "/{->" + logdic_candidate.gsub(/;/, '~;') + "/}"
      else # �������Ф�
	addition[key] = " /" + logdic_candidate + "/"
      end
    end
    if modification.size > 0
      changelog += "Modify the following "
      if modification.size == 1
	changelog += "entry.\n"
      else
	changelog += "entries.\n"
      end
      modification.sort.each do |key,candidate|
	temp = key + candidate + "\n"
	if fold
	  opt = '-jf310'
	else
	  opt = '-j'
	end
	temp = NKF.nkf(opt, temp)
	changelog += "\t  " + temp
      end
    end
    if (addition.size > 0)
      if modification.size > 0
	changelog += "\n\t"
      end
      changelog += "Add the following "
      if (addition.size == 1)
	changelog += "entry.\n"
      else
	changelog += "entries.\n"
      end
      addition.sort.each do |key,candidate|
	temp = key + candidate + "\n"
	if fold
	  opt = '-jf310'
	else
	  opt = '-j'
	end
	temp = NKF.nkf(opt, temp)
	changelog += "\t  " + temp
      end
    end
    changelog
  end

  def make_wrong(fold)
    removal = Hash.new
    modification = Hash.new
    changelog = ""
    @logdic.each{|container| # �������ɤ߹��������
      key = container[0]
      largedic_candidate = @hash[key]
      if !largedic_candidate # wrong ����
	# �������Ȥ����������䤬�ʤ���
	next
      else
	largedic_candidate = largedic_candidate.join('/')
	largedic_candidate = '/' + largedic_candidate + '/'
      end
      container[1].each{|logdic_candidate|
	#log�����annotation��ʬ�򡦽���
	if /(.+);(.*)/ =~ logdic_candidate
	  annotation = $2
	  logdic_candidate = $1
	  if /[;\r\n\/\"]/ =~ annotation
	    annotation = annotation.gsub(/;/, '\\\073').gsub(/\//, '\\\057').gsub(/\r/, '\\r').gsub(/\n/, '\\n').gsub(/"/, '\\"')
	    annotation = '(concat "' + annotation + '")'
	  end
	end
	# L ����δ�¸�Υ���ȥ꤫��βý��� manued ��ɽ�����롣
	if /^\/#{Regexp.quote(logdic_candidate)};([^\/])+\/$/ =~ largedic_candidate
	  # L ����˺�����٤�����+annotation �����롣
	  old_annotation = $1
	  if annotation
	    largedic_candidate = " \/#{logdic_candidate}~;#{old_annotation}\/->;#{annotation}}"
	  else
	    largedic_candidate = " \/#{logdic_candidate}~;#{old_annotation}\/->}"
	  end
	  if !removal[key]
	    removal[key] = Array.new
	  end
	  removal[key].push(largedic_candidate)
	elsif /^\/#{Regexp.quote(logdic_candidate)}\/$/ =~ largedic_candidate
	  # L ����� ������٤����� (annotation �Ϥʤ�) �����롣
	  if annotation
	    largedic_candidate = " \/#{logdic_candidate}->;#{annotation}\/}"
	  else
	    largedic_candidate = " \/#{logdic_candidate}->\/}"
	  end
	  if !removal[key]
	    removal[key] = Array.new
	  end
	  removal[key].push(largedic_candidate)
	elsif /(.*)\/#{Regexp.quote(logdic_candidate)};([^\/])+\/(.*)$/ =~ largedic_candidate
	  #elsif /(.+)*\/#{logdic_candidate};([^\/])*(.+)*$/ =~ largedic_candidate
	  # L ����˺�����٤����� + annotation ������(ʣ������)��
	  prefix = $1
	  old_annotation = $2
	  postfix = $3
	  if annotation
	    largedic_candidate = " #{prefix}{\/#{logdic_candidate}~;#{old_annotation}->;#{annotation}}\/#{postfix}"
	  else
	    largedic_candidate = " #{prefix}{\/#{logdic_candidate}~;#{old_annotation}->}\/#{postfix}"
	  end
	  if !modification[key]
	    modification[key] = Array.new
	  end
	  modification[key].push(largedic_candidate)
	elsif /(.*)\/#{Regexp.quote(logdic_candidate)}\/(.*)$/ =~ largedic_candidate
	  # L ����˺�����٤����� (annotation �Ϥʤ�) ������(ʣ������)��
	  prefix = $1
	  postfix = $2
	  if annotation
	    largedic_candidate = " #{prefix}{\/#{logdic_candidate}->;#{annotation}}\/#{postfix}"
	  else
	    largedic_candidate = " #{prefix}{\/#{logdic_candidate}->}\/#{postfix}"
	  end
	  if !modification[key]
	    modification[key] = Array.new
	  end
	  modification[key].push(largedic_candidate)
	end
      }
    }
    if modification.size > 0
      changelog += "Modify the following "
      if modification.size == 1
	changelog += "entry.\n"
      else
	changelog += "entries.\n"
      end
      modification.sort.each do |ct|
	key = ct[0]
	ct[1].each do |candidate|
	  temp = key + candidate + "\n"
	  if fold
	    opt = '-jf310'
	  else
	    opt = '-j'
	  end
	  temp = NKF.nkf(opt, temp)
	  changelog += "\t  " + temp
	end
      end
    end
    if (removal.size > 0)
      if modification.size > 0
	changelog += "\n\t"
      end
      changelog += "Remove the following "
      if removal.size == 1
	changelog += "entry.\n"
      else
	changelog += "entries.\n"
      end
      removal.sort.each do |ct|
	key = ct[0]
	ct[1].each do |candidate|
	  temp = key + candidate + "\n"
	  if fold
	    opt = '-jf310'
	  else
	    opt = '-j'
	  end
	  temp = NKF.nkf(opt, temp)
	  changelog += "\t  {" + temp
	end
      end
    end
    changelog
  end

  def make_dichash(dicfile)
    hash = Hash.new
    dicfile = File.expand_path(dicfile)
    File.foreach(dicfile) do |line|
      candidates = Array.new
      if (line =~ /^([^ ]+) \/(.+)\//)
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
    hash
  end

end

# end of changelog.rb
