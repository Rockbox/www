#!/bin/bash

# This script should get a builds file on stdin, and will append the
# recalibrated lines in "newbuildfile". Run it from a rockbox checkout

while read 
do
   zipneeded=`echo "$REPLY"|cut -f 2 -d ":"`
   shortname=`echo "$REPLY"|cut -f 3 -d ":"`
   nicename=`echo "$REPLY"|cut -f 4 -d ":"`
   various=`echo "$REPLY"|cut -f 1-6 -d ":"`
   args=`echo "$REPLY"|cut -f 6 -d ":"|tr ',' ' '`
   mkdir -p build-calibrate
   cd build-calibrate
   echo -n "building $nicename : "
   if [ "$zipneeded" = "zip" ]
   then
      /usr/bin/time -f"%U+%S" sh -c "../tools/configure --no-ccache $args && make -j && make zip">/dev/null 2>../$shortname.buildtime
   else
      /usr/bin/time -f"%U+%S" sh -c "../tools/configure --no-ccache $args && make -j ">/dev/null 2>../$shortname.buildtime
   fi
   cd ..
   rm -rf build-calibrate
   score=`cat $shortname.buildtime|tail -1|bc -l|numprocess '*100'|numround`
   rm -f  $shortname.buildtime
   echo $score
   echo "$various:$score" >> newbuildfile
done

