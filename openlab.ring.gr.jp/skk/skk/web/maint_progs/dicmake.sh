#!/bin/sh
# Making new dictionary archive

PATH=$HOME/bin:/usr/local/bin:/sbin:${PATH:-/usr/bin:.}
export PATH
umask 002
cd /circus/openlab/skk/skk/dic
cvs update -dP
#make SKK-JISYO.wrong
if make archive
then
        mv -f /circus/openlab/skk/skk/dic/*.gz* /circus/openlab/skk/dic
        mv -f /circus/openlab/skk/skk/dic/*.bz2* /circus/openlab/skk/dic
        mv -f /circus/openlab/skk/skk/dic/*.zip* /circus/openlab/skk/dic
	make clean
fi
# end of dicmake.sh