#!/bin/sh

build=$1
client=$2
rev=$3

perl checksize.pl $build
perl checklog.pl $rev $build

if [ -e rcbuild.hash ]; then
    hash=`cat rcbuild.hash`
    if [ "a$hash" = "a$rev" ]; then
        upload=`fgrep ":$build:" builds | cut -d: -f2`
        if [ $upload -eq 1 ]; then
            rcdir=/home/rockbox/download/release-candidate/$rev
            filename="rockbox-$build.zip"
            cp data/$filename $rcdir
            echo "$1=$rev,http://download.rockbox.org/release-candidate/$rev/$filename" >> build-info.release-candidate
        fi
    fi
fi
