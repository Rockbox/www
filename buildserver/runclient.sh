#!/bin/sh
trap "exit" INT

while true
do
    if [ -f "rbclient.pl.new" ]; then
        mv "rbclient.pl.new" "rbclient.pl"
    fi
    perl -s rbclient.pl -username= -password= -clientname= -archlist=m68k-gcc452,sh,mipsel,sdl,arm-eabi-gcc444,arm-ypr0-gcc446,android15 -buildmaster=buildmaster.rockbox.org -port=19999
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
    sleep 30
done
