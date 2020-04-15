#!/bin/sh
trap "exit" INT

while true
do
    if [ -f "rbclient.pl.new" ]; then
        mv "rbclient.pl.new" "rbclient.pl"
    fi
    # Possible values for archlist are:

    # arm-eabi-gcc444 : needed for ARM-based traditional targets
    # arm-rb-gcc494   : linux based sony players, Samsung YP-R0 YP-R1
    # sh : SH-based players, i.e. the Archoses
    # m68k-gcc452 : coldfire-based players
    # mipsel-gcc494 : MIPS-based players
    # mipsel-rb-gcc494: linux based MIPS players i.e Agptek Rocker (Benjie T6)
    # sdl : Non-crosscompiled targets. Simulators, application, checkwps, database tool, ...
    # android-ndk10: Android NDK 10e, for ibasso dx50/dx90
    # android-ndk10sdk19: Android NDK 10e and SDK supporting v4.4 (API 19)
    # latex : manuual

    perl -s rbclient.pl -username= -password= -clientname= -archlist=m68k-gcc452,sh,mipsel-gcc494,sdl,arm-eabi-gcc444,arm-ypr0-gcc446,android16 -buildmaster=buildmaster.rockbox.org -port=19999
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
    sleep 30
done
