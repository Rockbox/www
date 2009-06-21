#!/bin/sh
trap "exit" INT

while true
do
    perl rbclient.pl -username= -password= -archlist=arm -clientname=
done
