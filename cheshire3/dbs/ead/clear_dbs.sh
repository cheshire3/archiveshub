#!/bin/sh

# clever work-around to avoid "Argument list too long" error
find /home/cheshire/cheshire3/install/htdocs/ead/html/ -name '*.shtml' -print0 | xargs --null rm -f
find /home/cheshire/cheshire3/install/htdocs/ead/tocs/ -name '*.inc' -print0 | xargs --null rm -f

current=`pwd`

cd /home/cheshire/cheshire3/cheshire3/dbs/ead
rm -f stores/*.bdb
# rm -rf indexes/* # this is now handled within Cheshire3

./cluster/clear_dbs.sh

cd $current
