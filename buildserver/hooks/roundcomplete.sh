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
    perl showsize.pl 1 > sizes2.html.new && mv sizes2.html.new sizes2.html
    perl devbuilds.pl $rev > devbuilds.html.new && mv devbuilds.html.new devbuilds.html
    # created by devbuilds.pl
    mv build-info.new /home/rockbox/download/build-info.devbuild

    # udpate local git repo
    (cd $ROCKBOX_GIT_DIR && git pull -q --stat )

    (cd $ROCKBOX_GIT_DIR/tools && ./build-info.pl > build-info.new && \
     mv build-info.new /home/rockbox/download/build-info.release)

    # Cleanup.  Must happen AFTER git update
    perl cleanupdatadir.pl

    # Mark themesite and translate as needing to be updated
    # see $HOME/update_site.sh for details
    touch ../../translate/need_update
    touch ../../themes/need_update

fi

rm data/build_running

# make build-info for rbutil
cd /home/rockbox/download
sh .scripts/mkbuildinfo.sh
