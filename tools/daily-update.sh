#!/bin/sh

. ~/.bash_profile

export NUM_PARALLEL=4

cd /home/rockbox/rockbox_git_clone
version=`git rev-parse --verify --short HEAD 2>/dev/null`
git archive --prefix=rockbox-$version/ -o ../dailybuild/input/rockbox-source.tar HEAD
xz -f ../dailybuild/input/rockbox-source.tar

cd /home/rockbox/dailybuild
./rmold.sh
date > buildall.log
nice ./buildall-zips.pl -v >>buildall.log 2>&1
datex=`ls -r output/build-info-2* | head -1 | cut -f3 -d'-'`
./dailychanges.sh $datex
date >> buildall.log
nice ./buildall-manuals.pl -v >>buildall.log 2>&1  # XXX
date >> buildall.log
nice ./buildall-voices.pl -v >>buildall.log 2>&1
date >> buildall.log

# sync up with real download server
#rsync -avr -e "ssh -i ~/.ssh/rb_id"  --delete ~/download rockbox@archos.rockbox.org:

