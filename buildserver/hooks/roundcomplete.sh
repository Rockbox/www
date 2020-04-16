#!/bin/sh

rev=$1

rcbuild=0;
if [ -e rcbuild.hash ]; then
    hash=`cat rcbuild.hash`
    if [ "a$hash" = "a$rev" ]; then
        rcbuild=1;
    fi
fi

if [ $rcbuild -eq 1 ]; then
    # publish the release candidate for rbutil
    mv build-info.release-candidate /sites/download.rockbox.org/release-candidate/build-info
    rm rcbuild.hash
fi

    # talk to rasher before removing this
    cat data/$rev*.size > data/$rev.sizes

    perl clientstats.pl $rev > data/$rev-clients.html

    perl showbuilds.pl > builds.html
    perl showbuilds.pl 1 > builds_all.html
    perl showsize.pl > sizes.html
    perl mktitlepics.pl
    perl cleanupdatadir.pl

    # make build-info for rbutil
    echo "[bleeding]" > build-info
    date +'timestamp = "%Y%m%dT%H%M%SZ"' >> build-info
    echo -n 'rev = "' >> build-info
    echo -n $rev >> build-info
    echo '"' >> build-info
    mv build-info /sites/download.rockbox.org/build-info.devbuild
fi

rm data/build_running

# make build-info for rbutil
cd /sites/download.rockbox.org
sh .scripts/mkbuildinfo.sh
