#!/bin/sh
trap "exit" INT

while true
do
    perl -s rbclient.pl -username= -password= -archlist=arm -clientname=
done
