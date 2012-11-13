#!/bin/sh

# clever work-around to avoid "Argument list too long" error
find $C3ARCHIVESHOME/www/htdocs/ead/html/ -name '*.shtml' -print0 | xargs --null rm -f
find $C3ARCHIVESHOME/www/htdocs/ead/tocs/ -name '*.inc' -print0 | xargs --null rm -f

current=`pwd`

cd $C3ARCHIVESHOME/dbs/ead

 
FILE="indexing.lock"
if test -f $FILE
    then
        echo "ERROR: Another user is currently indexing this database. Please try again 
in 10 minutes. If you continue to get this message and you are sure no one 
is reindexing the database please contact the archives hub team for advice."
    else
		touch $FILE
		rm -f stores/*.bdb
		rm -rf indexes/*
		./cluster/clear_dbs.sh
		rm $FILE
		cd $current
fi