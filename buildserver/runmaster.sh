#!/bin/sh
trap "exit" INT

while true
do
    nice perl rbmaster.pl
    res=$?
    sleep 5;
done
