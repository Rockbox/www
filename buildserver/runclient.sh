#!/bin/sh
trap "exit" INT

while true
do
    perl -s rbclient.pl -username= -password= -archlist=arm,m68k,sh,mipsel,sdl -clientname=
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
done
