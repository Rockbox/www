#!/bin/sh

# remove files more than 14 days old (ie match binary retention)
find -L output -type f -mtime +14 -exec rm {} \;

# Remove unused voice pool files
#find -L voice-pool -type f -mtime +7 -exec rm {} \;

# ensure we get rid of all old inputs too
while true ; do
    builds=`wc -l < ../buildserver-data/lastNbuilds`
    if [ $builds -lt 20 ] ; then
        break
    fi
    one=`head -n 1 ../buildserver-data/lastNbuilds`
    echo "DELETING FILES FOR $one"
    rm ../buildserver-data/*$one*
    tail -n `expr $builds - 1` ../buildserver-data/lastNbuilds > updated
    mv updated ../buildserver-data/lastNbuilds
done
# until then... just purge anything older than two weeks?
find -L input -type f -mtime +14 -exec rm -f {} \;
