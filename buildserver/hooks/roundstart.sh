#!/bin/sh

rev=$1

touch data/build_running
perl showbuilds.pl $rev > builds.html.new && mv builds.html.new builds.html

if [ -e rcbuild.hash ]; then
    hash=`cat rcbuild.hash`
    if [ "a$hash" = "a$rev" ]; then
        rcdir=/home/rockbox/download/release-candidate
        rm -rf $rcdir/*
        if [ ! -d $rcdir/$rev ]; then
            mkdir -p $rcdir/$rev
        fi
        echo "[release-candidate]" > build-info.release-candidate
    fi
fi
#rm -f data/rockbox-*.zip
#rm -f data/rockbox.7z

(cd ../../rockbox_git_clone && git pull -q --stat )
