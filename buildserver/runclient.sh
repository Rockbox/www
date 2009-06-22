#!/bin/sh
trap "exit" INT
olddir="`pwd`"
cd "`dirname $0`"

while true
do
    perl -s rbclient.pl -username= -password= -archlist=arm -clientname=
done
cd "$olddir"
