#!/bin/sh
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Keywords: japanese, web maintenance
#
### Commentary:
# This file is to be called from CVSROOT/loginfo.
export HOME=/home/minakaji
cd /circus/openlab/skk/skk && \
CVSREAD=1 /usr/local/bin/cvs -Q update -dP && \
/bin/rm -f /circus/openlab/skk/skk/web/*.html; \
/bin/rm -f /circus/openlab/skk/*.html; \
/bin/cp -f /circus/openlab/skk/skk/web/*.html.in /circus/openlab/skk; \
cd /circus/openlab/skk/ && \
for i in *.html.in ; do newname=$(basename $i .in); mv -f $i $newname; done; \
cd $HOME/tmp && \
wget --no-check-certificate https://raw.github.com/skk-dev/ddskk/master/doc/skk.texi;\
/usr/local/bin/nkf -e skk.texi > $HOME/tmp/skk-manual-ja.texi;\
$HOME/bin/texi2html -frame -split=chapter $HOME/tmp/skk-manual-ja.texi;\
/bin/mv -f $HOME/tmp/*.html /circus/openlab/skk/skk-manual;\
rm -f $HOME/tmp/skk-manual-ja.texi $HOME/tmp/skk.texi
#find . -exec chown www /circus/openlab/skk/log/*.log /usr/sbin/chown  {} \;
# end of cvswork.sh
