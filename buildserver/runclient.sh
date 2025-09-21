#!/bin/sh
trap "exit" INT

# Set this to where you want temporary build files to reside
# If not set, files will live under the rockbox git directory

while true
do
    if [ -f "rbclient.pl.new" ]; then
        mv "rbclient.pl.new" "rbclient.pl"
    fi

    ############### Possible values for archlist are:

    ####### Native targets
    # m68k-gcc950            : m68k-based players
    # arm-eabi-gcc950        | arm-based players
    # mipsel-gcc950          : MIPS-based players

    ####### Hosted
    # mipsel-rb-gcc950       : linux based MIPS players, eg Agptek Rocker (Benjie T6)
    # arm-rb-gcc950          : linux based ARM players, eg Samsung YP-R0/YP-R1

    ####### Special
    # sdl2 : Non-crosscompiled targets. Simulators, application, checkwps, database tool, ...
    # latex : manuals
    # qt5 :  For building rbutil and themeeditor
    # qt6 :  For building rbutil and themeeditor
    # dummy : does nothing

    ####### Android
    # android-ndk10          : Android NDK 10e, eg iBasso dx50/dx90
    # android-ndk10sdk19     : Android NDK 10e and SDK+tools supporting API 19 (4.4/KitKat)
    ####### Other
    # funkey-sdk             : Funkey SDK (eg for FunKey handheld or Ambergic RG Nano)

    # CHANGEME:  This list includes native targets only.
    perl -s rbclient.pl -username= -password= -clientname= -buildroot= -archlist=m68k-gcc950,mipsel-gcc950,arm-eabi-gcc950 -buildmaster=buildmaster.rockbox.org -port=19999
    res=$?
    if test "$res" -eq 22; then
      echo "Address the above issue(s), then restart!"
      exit
    fi
    sleep 30
done
