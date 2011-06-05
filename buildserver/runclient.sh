#!/bin/sh
trap "exit" INT

while true
do
    if [ -f "rbclient.pl.new" ]; then
        mv "rbclient.pl.new" "rbclient.pl"
    fi
    perl -s rbclient.pl -username= -password= -archlist=arm,m68k,sh,mipsel,sdl,arm-eabi-gcc444 -clientname=
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
    sleep 30
done
