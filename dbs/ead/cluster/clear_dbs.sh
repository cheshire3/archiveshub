#!/bin/sh

current=`pwd`
cd $C3ARCHIVESHOME/dbs/ead/cluster
rm -f stores/*.bdb
# rm -rf indexes/* # this is now handled within Cheshire3
rm -f tempCluster.*
cd $current
