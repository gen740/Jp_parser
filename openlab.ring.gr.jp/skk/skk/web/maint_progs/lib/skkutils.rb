# Copyright (C) 2002 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: skkutils.rb,v 1.3 2003/04/03 12:34:58 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2003/04/03 12:34:58 $

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
def cut_off_prefix_postfix(string)
  string.sub(/^[<>\?]([¡¼¤¡-¤ó]+)$/, '\1').sub(/^([¡¼¤¡-¤ó]+)[<>\?]$/, '\1')
end

# def cut_off_prefix_postfix(string)
#   if /^[<>\?]([¡¼¤¡-¤ó]+)$/ =~ string
#     string = $1
#   elsif /^([¡¼¤¡-¤ó]+)[<>\?]$/ =~ string
#     string = $1
#   end
#   string
# end

# end of skkutils.rb
