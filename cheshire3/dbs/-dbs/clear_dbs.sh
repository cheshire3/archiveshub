#!/bin/sh

# clever work-around to avoid "Argument list too long" error
find /home/cheshire/cheshire3/install/htdocs/ead/html/ -name '*.shtml' -print0 | xargs --null rm -f
find /home/cheshire/cheshire3/install/htdocs/ead/tocs/ -name '*.inc' -print0 | xargs --null rm -f

rm -f stores/*.bdb
rm -rf indexes/*
rm -f cluster/*.bdb
rm -f cluster/stores/*.bdb
rm -rf cluster/indexes/*
rm -f tempCluster.*


