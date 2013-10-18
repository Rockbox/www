#!/bin/bash

# This script should get a builds file on stdin, and will append the
# recalibrated lines in "newbuildfile". Run it from a rockbox checkout

while read 
do
   zipneeded=`echo "$REPLY"|cut -f 2 -d ":"`
   shortname=`echo "$REPLY"|cut -f 3 -d ":"`
   nicename=`echo "$REPLY"|cut -f 4 -d ":"`
   various=`echo "$REPLY"|cut -f 1-5 -d ":"`
   oldscore=`echo "$REPLY"|cut -f 6 -d ":"`
   command=`echo "$REPLY"|cut -f 7 -d ":"`
   mkdir -p build-calibrate
   cd build-calibrate
   echo -n "building $nicename : "
   /usr/bin/time -f"%U+%S" sh -c "$command" >/dev/null 2>../$shortname.buildtime
   cd ..
   rm -rf build-calibrate
   score=`cat $shortname.buildtime|tail -1|bc -l|numprocess '*1000'|numround`
   rm -f  $shortname.buildtime
   echo $score
   echo "$various:$score:$command" >> newbuildfile
done
