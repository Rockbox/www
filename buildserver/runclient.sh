#!/bin/sh
trap "exit" INT

while true
do
    perl -s rbclient.pl -username=daniel -password=looser -archlist=arm,m68k,sh,mipsel,sdl -clientname=storebror
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
done
