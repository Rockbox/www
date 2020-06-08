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
    mv build-info.release-candidate /home/rockbox/download/release-candidate/build-info
    rm rcbuild.hash
else

    perl clientstats.pl $rev > data/$rev-clients.html

    perl showbuilds.pl > builds.html.new && mv builds.html.new builds.html
    perl showbuilds.pl 1 > builds_all.html.new && mv builds_all.html.new builds_all.html
    perl showsize.pl > sizes.html.new && mv sizes.html.new sizes.html
    perl devbuilds.pl > devbuilds.html.new && mv devbuilds.html.new devbuilds.html
#    perl mktitlepics.pl
    perl cleanupdatadir.pl

    # make build-info for rbutil
    echo "[bleeding]" > build-info.new
    date +'timestamp = "%Y%m%dT%H%M%SZ"' >> build-info.new
    echo -n 'rev = "' >> build-info.new
    echo -n $rev >> build-info.new
    echo '"' >> build-info.new
    mv build-info.new /home/rockbox/download/build-info.devbuild

    # udpate local git repo
    (cd ../../rockbox_git_clone && git pull -q --stat )

    # Mark themesite and translate as needing to be updated
    # see $HOME/update_site.sh for details
    touch ../../translate/need_update
    touch ../../themes/need_update
fi

rm data/build_running

# make build-info for rbutil
cd /home/rockbox/download
sh .scripts/mkbuildinfo.sh
