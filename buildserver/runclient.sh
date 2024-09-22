#!/bin/sh
trap "exit" INT

while true
do
    if [ -f "rbclient.pl.new" ]; then
        mv "rbclient.pl.new" "rbclient.pl"
    fi

    ############### Possible values for archlist are:

    ####### Native targets
    # m68k-gcc494            : m68k-based players
    # arm-eabi-gcc494        | arm-based players
    # mipsel-gcc494          : MIPS-based players

    ####### Hosted
    # mipsel-rb-gcc494       : linux based MIPS players, eg Agptek Rocker (Benjie T6)
    # arm-rb-gcc494          : linux based ARM players, eg Samsung YP-R0/YP-R1

    ####### Special
    # sdl : Non-crosscompiled targets. Simulators, application, checkwps, database tool, ...
    # sdl2 : (will replace 'sdl')
    # latex : manuual
    # dummy : does nothing

    ####### Android
    # android-ndk10          : Android NDK 10e, eg iBasso dx50/dx90
    # android-ndk10sdk19     : Android NDK 10e and SDK+tools supporting API 19 (4.4/KitKat)

    # CHANGEME:  This list includes native targets only.
    perl -s rbclient.pl -username= -password= -clientname= -archlist=m68k-gcc494,mipsel-gcc494,arm-eabi-gcc494 -buildmaster=buildmaster.rockbox.org -port=19999
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
    sleep 30
done
