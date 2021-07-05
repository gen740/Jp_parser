#!/bin/sh
for file in `find . -type f`;
do
    echo $file
    iconv -f euc-jp -t utf-8 $file > tmpfile
    mv tmpfile $file
done
exit
