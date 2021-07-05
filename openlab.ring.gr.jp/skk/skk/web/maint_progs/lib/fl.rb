# Copyright (C) 2002 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
#                    Kazuhiro NISHIYAMA <zn@mbf.nifty.com>
#
# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
#         Kazuhiro NISHIYAMA <zn@mbf.nifty.com>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: fl.rb,v 1.1 2002/10/14 01:01:43 minakaji Exp $
# Keywords: japanese, dictionary, web maintenance
# Last Modified: $Date: 2002/10/14 01:01:43 $

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

## Commentary:

class FileLockDir
  def lock(lockdir)
    Dir.mkdir(lockdir)
    return true
  rescue Errno::EEXIST
    return false
  end

  def unlock(lockdir)
    Dir.rmdir(lockdir)
    return true
  rescue
    return false
  end
end

# end of fl.rb
