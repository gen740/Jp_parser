#!/bin/sh
# making new distribution of main elisp package.

PATH=$HOME/bin:/usr/local/bin:/sbin:${PATH:-/usr/bin:.}
export PATH
umask 002
cd /circus/openlab/skk/skk/main

# 2015.1.7
# cvs update -dP
# if make snapshot
# then
#   mv -f /circus/openlab/skk/skk/ddskk*.tar.* /circus/openlab/skk/maintrunk
# fi

# end of ddmake.sh
